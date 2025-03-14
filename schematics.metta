!(bind! &kb (new-space))
(: Schema Type)
;;Time dependent schematics
;; schema constructor
(: Schema (-> $context $action  Schema))
(: truthValue Type)
;; The truth-value data-type containing second-order probabilities.
(: TV (-> Number Number truthValue))
(: ImplicationLink Type)
(: ImplicationLink (-> Schema $goal truthValue ImplicationLink))
(: TemporalImplicationLink Type)
(: TemporalImplicationLink (-> Schema $goal $time truthValue TemporalImplicationLink))



(=(get-schemas-with-time-cycle $kb $time-cycle)
    (collapse (match $kb (TemporalImplicationLink $schema $goal $time $truthValue) $schema))
    
)