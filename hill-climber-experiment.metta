!(bind! &action-space (new-space))
!(bind! &rule-space (new-space))

;; A proof of concept for the hill climbing algorithm

(: Action Type)
(: State Type)
(: state (-> Symbol State))
(: action (-> Symbol Action))
(= (add-actions $space)
    (add-reduct $space (superpose ( 
                            (action eat)
                            (action walk)
                            (action turn)

                            )
            )
    )
)
(= (add-states $space)
    (add-reduct $space (superpose (
                    (state hungry)
                    (state satisfied)
            )
        )
    )
)

;; (= (hill-climbing $space)
;;     ()
;; )

(= (add-action $space $verb)
    (add-atom $space (action $verb))
)
!(add-actions &action-space)
!(add-action &action-space write)
!(get-atoms &action-space)