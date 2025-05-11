(= (complexity $exp)
    (size-atom $exp)
)

(= (prior $compPenality $len)
    ((py-atom numpy.exp) (* $compPenality $len))
)

(= (unexplainedDataSize $dataSetSize $tvCount) (- $dataSize $tvCount))

(= (kolmogorov_estimate $remainCount $compressiveness)
    (pow-math $remainCount (- 1 $compressiveness))
)

(= (priorEstimate  $atom $dataSetSize $tvCount $compPenality $remainCount $compressiveness)
    (let* (
        ($partialComplexity (complexity $atom))
        ($unexplainedSize (unexplainedDataSize $dataSetSize $tvCount))
        ($kestimate (kolmogorov_estimate $remainCount $compressiveness))


    )
        (prior $compPenality (+ $partialComplexity $kestimate))
    )
)

