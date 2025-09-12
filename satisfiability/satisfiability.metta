!(bind! &curr (new-space))


(= (isMemberOfSpace $l $space)
    (let $found (collapse (match $space $l $l)) (if (== $found ()) false true))
)


;; !(add-reduct &curr (superpose ((first) (second) (third) (fourth))))
;; !(isMemberOfSpace (first) &curr)
