!(bind! &kb (new-space))
!(bind! &category-space (new-space)) ;; a space for adding new categories
(: Schema Type)
;;Time dependent schematics
;; schema constructor
(: SchemaCon (-> $context $action  Schema))
(: truthValue Type)
;; The truth-value data-type containing second-order probabilities.
(: stv (-> Number Number truthValue))
(: ImplicationLinkType Type)
(: ImplicationLink (-> Schema $goal truthValue ImplicationLinkType))
(: TemporalImplicationLinkType Type)
(: TemporalImplicationLink (-> Schema $goal $time truthValue TemporalImplicationLinkType))
(: Category Type)
(: category (-> Symbol Category))
(: Goal Type)
(: goal (-> Symbol Goal))
(: Link Type)
(: link (-> Category Symbol Link))

!(let $schema (SchemaCon context first_action)
    (get-type $schema)
)

(= (get-schemas-with-time-cycle $kb $time-cycle) (collapse (match $kb (TemporalImplicationLink $schema $goal $time $truthValue) $schema)))


(: add-category (-> hyperon::space::DynSpace Symbol empty))
(= (add-category $space $name) (add-atom $space (category $name)))