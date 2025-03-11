!(bind! &kb (new-space))
(: Schema Type)
;;Time dependent schematics
;; schema constructor
(: Scon (-> $context $action  Schema))
(: truthValue Type)
;; The truth-value data-type containing second-order probabilities.
(: TV (-> Number Number truthValue))
(: ImplicationLink Type)
(: ImplicationLink (-> Schema $goal truthValue ImplicationLink))
(: TemporalImplicationLink Type)
(: TemporalImplicationLink (-> Schema $goal $time truthValue TemporalImplicationLink))


!(let* (
    ($schema (scon first act 2 final))
    ($second-schema (scon first act final))
    ($type (get-type $schema))
    ($type-2 (get-type $second-schema))
)
    ($type $type-2)
)
(=(get-schemas-with-time-cycle $kb $time-cycle)
    (collapse (match $kb (TemporalImplicationLink $schema $goal $time $truthValue) $schema))
    
)