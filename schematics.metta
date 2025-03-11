!(bind! &kb (new-space))
(: schema Type)
(: operator Type)
;;Time dependent schematics
;; scon stands for schema constructor
(: scon (-> $context $action $time $goal schema))
;;Time independent schematics
(: scon (-> $context $action $goal schema))
(: truthValue Type)
;; The truth-value data-type containing second-order probabilities.
(: Tv (-> Number Number truthValue))
(: ImplicationLink Type)
(: ImplicationLink (-> schema goal truthValue ImplicationLink))


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