!(bind! &action-space (new-space))
!(mod-space! stdlib)
(: Action Type)

(= (add-action $space $verb)
    (add-atom $space (: $verb Action))
)

!(add-action &action-space write)
!(get-atoms &action-space)