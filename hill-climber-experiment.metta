!(bind! &action-space (new-space))
!(bind! &rule-space (new-space))
!(bind! &state-space (new-space))

;; A proof of concept for the hill climbing algorithm
;; I took operators as actions

(: Action Type)
(: State Type)
(: Rule Type)
(: rule (-> State Action Number Rule))
(: state (-> Symbol State))
(: action (-> Symbol Action))
(= (add-actions $space)
    (add-reduct $space (superpose ( 
                            (action idle)
                            (action walk)
                            (action turn)
                            (action eat)

                            )
            )
    )
)
(= (add-states $space)
    (add-reduct $space (superpose (
                    (state hungry)
                    (state hope)
                    (state satisfied)
            )
        )
    )
)
(= (add-rules $space)
    (add-reduct $space (superpose (
        (rule (state hungry) (action idle) (state hungry) 0)
        (rule (state hungry) (action walk) (state hope) 0.3)
        (rule (state hope) (action eat) (state satisfied) 0.7)

    )))
)

(= (add-action $space $verb)
    (add-atom $space (action $verb))
)
(= (hill-climb-planner $init-state $init-action $goal)
    (let $goals (collapse (match &rule-space (rule (state $init-state) (action $init-action) $x $y)))

    )

)

!(add-actions &action-space)
!(add-action &action-space write)
!(get-atoms &action-space)

;; (= (blend $concept1 $concept2) (union-atom $concept1 $concept2))
;; !(blend (fir) (sec))