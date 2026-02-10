!(import! &self nars-planner)
!(import! &self sampler)
!(import! &self ../environment/utils)
!(import! &self ../environment/world)
!(import! &self ../environment/galactic-rules)
!(import! &self rule-helpers)
!(import! &self reasoning)
!(import! &self utils)

!(bind! &ruleSpace (new-space))

;;Subject = (AND Context Action)
;;Predicate = Goal
;;Statement = (Subject --> Predicate)


(= (nars-reasoning $rules) (
    let* (
        ($deductions (applyDeduction $rules))
        ($inductions (applyInduction $rules))
        ($abductions (applyAbduction $rules))
        ($exemplifications ()) ;; Todo
    )
    (union-atom $deductions (union-atom $inductions (union-atom $abductions $exemplifications)))
))

(= (loop $contexts $money $ruleSpace $depth) (
    if (== $depth 0)
        (println! (DONE))
        (let* (
            ($rules (collapse (get-atoms $ruleSpace)))
            ($reasonedRules (nars-reasoning $rules))
            ; ($_ (println! ("Reasoned Rules: " ( $reasonedRules))))
            ($_ (collapse (let $rule (superpose $reasonedRules) (add-atom $ruleSpace $rule))))
            ($combinedRules (union-atom $rules $reasonedRules))
            ($_ (println! ("Combined Rules: " (size-atom $combinedRules))))
            
            ($applicableRules (getApplicableRules $contexts $money $combinedRules))
            ($_ (println! (Applicable Rules: ( $applicableRules))))
            (($score $selectedRule) (thompson-sample $applicableRules))
            ($_ (println! ("Selected Rule:"  $selectedRule with score: $score)))
            (($newContexts $newMoney) (applyRule $selectedRule $contexts $money))
            ($_ (println! (Updated: $newContexts $newMoney)))
            ($oldStateValue (evaluateState $contexts $money))
            ($_ (println! (Old State Value: $oldStateValue)))
            ($newStateValue (evaluateState $newContexts $newMoney))
            ($_ (println! (New State Value: $newStateValue)))
            ($reward (- $newStateValue $oldStateValue))
            ($_ (println! (Reward: $reward)))
            ($updatedRule (updateRule $selectedRule $reward))
            ($_ (collapse (updateAtom $selectedRule $updatedRule $ruleSpace)))
        )
    (loop $newContexts $newMoney $ruleSpace (- $depth 1)))
))

!(collapse (addWorldRules &ruleSpace))

!(loop (((PLANET A) (STV 0.2 0.1))) 100 &ruleSpace 2)