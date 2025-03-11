!(bind! &kb (new-space))
(: schema Type)
;;Time dependent schematics
;; schema constructor
(: Scon (-> $context $action  schema))
(: truthValue Type)
;; The truth-value data-type containing second-order probabilities.
(: TV (-> Number Number truthValue))
(: ImplicationLink Type)
(: ImplicationLink (-> schema $goal truthValue ImplicationLink))
(: TemporalImplicationLink Type)
(: TemporalImplicationLink (-> schema $goal $time truthValue TemporalImplicationLink))


!(let* (
    ($schema (scon first act 2 final))
    ($second-schema (scon first act final))
    ($type (get-type $schema))
    ($type-2 (get-type $second-schema))
)
    ($type $type-2)
)
(=(get-schemas-with-time-cycle $kb $time-cycle)
    (collapse (match $kb (scon $context $action $time-cycle $goal)))
)