!(import! &self perception-updater-agent)
!(bind! &perceptaSpace (new-space))
!(import! &self miner)
!(addPerceptions &perceptaSpace (
  (perception 5 (see ball red))
  
  (perception 5 (hear alarm loud))
  
  (perception 5 (feel temperature cold))
  
  (perception 5 (smell smoke faint))
  
  (perception 5 (taste food sweet))
  
  (perception 5 (see door open))
  
  (perception 5 (detect motion quick))
  
  (perception 5 (notice light dim))
  
  (perception 5 (sense danger high))
  
  (perception 5 (observe person walking))))



(: miner (-> hyperon::space::DynSpace Number Expression))
(= (miner $perceptaSpace $noOfRules)
    (let* (
          ($perceptaList (collapse (get-atoms $perceptaSpace)))
          ($instance (car-atom $perceptaList))
          ($perceptaPrint (pyModuleX simple_print ($instance)))
          ($llm_response (pyModuleX queryLlm  ($perceptaList $noOfRules)))
          ($preprocessedResult (pyModuleX preprocess_llm_response ($llm_response)))
    )
      $perceptaPrint
    )
)
;;!(pyModuleX queryLlm (((perception 3 (hear alarm loud)) (perception 4 (see door open))) 2))
!(simple_print "hi")
!(pyModuleX simple ())
!(miner &perceptaSpace 10)
