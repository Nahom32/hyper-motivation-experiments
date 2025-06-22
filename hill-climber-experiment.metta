!(bind! &action-space (new-space))
!(bind! &rule-space (new-space))
!(bind! &state-space (new-space))

;; A proof of concept for the hill climbing algorithm
;; I took operators as actions

(: Action Type)
(: State Type)
(: Rule Type)
(: rule (-> State Action State Number Rule))
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

    ))))

(= (add-action $space $verb)
    (add-atom $space (action $verb))
)
(: select-max (-> Expression Expression Expression))
( = (select-max $list $max)
    (if (== $list ())
        $max
        (let* (
            ((($x $y) $tail) (decons-atom $list))
            (($max-name $max-val) $max)
        )
        (if (<= $max-val $y)
            (select-max $tail ($x $y))
            (select-max $tail $max)
        )

        )
    )
)
(= (car-atom' $expr)
    (if (== $expr ())
        ()
        (car-atom $expr)
    )
)

(: hill-climb-planner (-> Symbol Symbol Symbol Expression Expression))
(= (hill-climb-planner $init-state $init-action $goal $accum)
    (if ( == $init-action $goal)
        $accum
        (let* ( 
            ($goal-vals (collapse (match &rule-space (rule (state $init-state) (action $init-action) (state $x) $y) ($x $y))))
            ($head-goal (car-atom $goal-vals))
            ($best-goal (select-max $goal-vals $head-goal))
            ($actions (collapse (match &rule-space (rule (state $best-goal) (action $x) (state $y) $z) ($x $z))))
            ($head-action (car-atom $actions))
            ($best-action (select-max $actions $head-action))
            ($newAccum (union-atom $accum ($init-action)))
        )
            (hill-climb-planner $best-goal $best-action $goal $newAccum)
        )
    )

)


!(add-actions &action-space)
!(add-action &action-space write)
!(add-rules &rule-space)
!(add-states &state-space)
!(collapse (match &rule-space 
                    (rule (state $init-state) (action $init-action) (state $x) $y) ($x $y)))
;; !(get-atoms &action-space)
!(hill-climb-planner hungry walk satisfied ())
;; (= (blend $concept1 $concept2) (union-atom $concept1 $concept2))
;; !(blend (fir) (sec))
