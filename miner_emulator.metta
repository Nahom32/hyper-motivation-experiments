!(import! &self miner)
!(import! &self perception-updater-agent)
!(bind! &perceptaSpace (new-space))
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
          ($llm_response (pyModuleX query_llm  $perceptaList $noOfRules))
          ($preprocessedResult (pyModuleX preprocess_llm_response $llm_response))
    )
      $preprocessedResult
    )
)

!(miner &perceptaSpace 10)
