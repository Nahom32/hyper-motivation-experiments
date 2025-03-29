!(bind! &kb (new-space))
(: Schema Type)
;;Time dependent schematics
;; schema constructor
(: SchemaCon (-> $context $action  Schema))
(: truthValue Type)
;; The truth-value data-type containing second-order probabilities.
(: TV (-> Number Number truthValue))
(: ImplicationLinkType Type)
(: ImplicationLink (-> Schema $goal truthValue ImplicationLinkType))
(: TemporalImplicationLinkType Type)
(: TemporalImplicationLink (-> Schema $goal $time truthValue TemporalImplicationLinkType))

!(let $schema (SchemaCon context first_action)
    (get-type $schema)
)

(= (get-schemas-with-time-cycle $kb $time-cycle) (collapse (match $kb (TemporalImplicationLink $schema $goal $time $truthValue) $schema)))