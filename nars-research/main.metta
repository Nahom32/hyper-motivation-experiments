!(import! &self nars-planner)
!(import! &self sampler)
!(import! &self world_utils)


;; (= (thompson-sample $rules) (
;;     if (== $rules ())
;;         (0 Nil)
;;         (let* (
;;             (($rule $tail) (decons-atom $rules))
;;             ($_ (println! (rule $rule)))
;;             ((STV $s $c) (extractRule STV $rule))
;;             ($_ (println! (s c $s $c)))
;;             ($ruleId (extractRule Id $rule))
;;             ($_ (println! (ruleId $ruleId)))
;;             (($alpha $beta) (stvToBeta ($s $c)))
;;             ($_ (println! (alpha-beta ($alpha $beta))))
;;             ($sampledValue (betaSample $alpha $beta))
;;             ($_ (println! (Rule $ruleId $sampledValue)))
;;             ($_ (println! (currMax $currMax currRule $currRule)))
;;             ($_ (println! (tail $tail)))
;;             (($currMax $currRule) (thompson-sample $tail))
            
;;         ) (if (> $sampledValue $currMax)
;;             ($sampledValue $rule)
;;             $currRule
;;         ))
;; ))
(= (updateRule $rule $result $ruleSpace) (
    let* (
        ($_ (println! ("Updating rule: " $rule " with result: " $result)))
        ((STV $strength $confidence) (extractRule STV $rule))
        (($alpha $beta) (stvToBeta ($strength $confidence)))
        ($newAlpha (if (== $result 1) (+ $alpha 1) $alpha))
        ($newBeta (if (== $result 1) $beta (+ $beta 1)))
        (($newStrength $newConfidence) (betaToSTV ($newAlpha $newBeta)))
        ($_ (println! ("Old STV: " ($strength $confidence) " New STV: " ($newStrength $newConfidence))))
        ;;($_ (updateSTV $rule ($newStrength $newConfidence) $ruleSpace))
    ) (updateSTV $rule ($newStrength $newConfidence) $ruleSpace)
))

;;(: updateSTV (-> Number (Number Number) hyperon::space::DynSpace (->)))
(= (updateSTV $rule ($s $c) $space) (
    let* (
        ;; ((: Rule $id $ttv (STV $os $oc) $comp $context $action $goal) $rule)
        ;; ($newRule (: Rule $id $ttv (STV $s $c) $comp $impl))
        ((: Rule $id $ttv (STV $os $oc) $complexity (IMPLICATION (AND $context $action) $goal)) $rule)
        ($newRule (: Rule $id $ttv (STV $s $c) $complexity (IMPLICATION (AND $context $action) $goal)))

        ($_ (println! (newRule $newRule)))
        ;;($_ )
    ) (updateAtom $space $rule $newRule)
))

(= (thompson-sampleHelper $rules $maxRule $maxVal)
    (if (== $rules ())
        ($maxVal $maxRule)
        (let* (
            (($rule $tail) (decons-atom $rules))
            ($_ (println! (rule $rule)))
            ((STV $s $c) (extractRule STV $rule))
            ($_ (println! (s c $s $c)))
            ($ruleId (extractRule Id $rule))
            ($_ (println! (ruleId $ruleId)))
            (($alpha $beta) (stvToBeta ($s $c)))
            ($_ (println! (alpha-beta ($alpha $beta))))
            ($sampledValue (betaSample $alpha $beta))
        )
            (if (> $sampledValue $maxVal)
                (thompson-sampleHelper $tail $rule $sampledValue)
                (thompson-sampleHelper $tail $maxRule $maxVal)
            )

        )
    )
)
(= (thompson-sample $rules)
    (if (== $rules ())
        (0 Nil)
        (let* (
            (($head $tail) (decons-atom $rules))
            ((STV $s $c) (extractRule STV $head))
            (($alpha $beta) (stvToBeta ($s $c)))
            ($sampledValue (betaSample $alpha $beta))
            ($_ (println! (alpha-beta ($alpha $beta))))
        )
            (thompson-sampleHelper $tail $head $sampledValue)
        )
    )
)

(= (greedySample $alpha $beta) (/ $alpha (+ $alpha $beta))) ;;Reference: A Tutorial on Thompson Sampling (Derrick Kingma et. al) (2019)
(= (greedyHelper $rules $maxRule $maxVal)
    (if (== $rules ())
        ($maxVal $maxRule)
        (let* (
            (($rule $tail) (decons-atom $rules))
            ($_ (println! (rule $rule)))
            ((STV $s $c) (extractRule STV $rule))
            ($_ (println! (s c $s $c)))
            ($ruleId (extractRule Id $rule))
            ($_ (println! (ruleId $ruleId)))
            (($alpha $beta) (stvToBeta ($s $c)))
            ($_ (println! (alpha-beta ($alpha $beta))))
            ;;($sampledValue (betaSample $alpha $beta))
            ($sampledValue (greedySample $alpha $beta))
        )
            (if (> $sampledValue $maxVal)
                (greedyHelper $tail $rule $sampledValue)
                (greedyHelper $tail $maxRule $maxVal)
            )

        )
    )
)
(= (greedySearch $rules)
    (if (== $rules ())
        (0 Nil)
        (let* (
            (($head $tail) (decons-atom $rules))
            ((STV $s $c) (extractRule STV $head))
            (($alpha $beta) (stvToBeta ($s $c)))
            ($sampledValue (betaSample $alpha $beta))
            ($_ (println! (alpha-beta ($alpha $beta))))
        )
            (greedyHelper $tail $head $sampledValue)
        )
    )
)

(= (addWorldRules $space)
    ;; Travel A -> B
    (let $rules (superpose (  
        ;; Travel A -> B
        (: Rule 1
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET A (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (TRAVEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET B (STV 0.2 0.1))
                )))
        ))

        ;; Travel A -> C
        (: Rule 2
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET A (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (TRAVEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET C (STV 0.2 0.1))
                )))
        ))

        ;; Travel B -> A
        (: Rule 3
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET B (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (TRAVEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET A (STV 0.2 0.1))
                )))
        ))

        ;; Travel B -> C
        (: Rule 4
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET B (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (TRAVEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET C (STV 0.2 0.1))
                )))
        ))

        ;; Travel C -> A
        (: Rule 5
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET C (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (TRAVEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET A (STV 0.2 0.1))
                )))
        ))

        ;; Travel C -> B
        (: Rule 6
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET C (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (TRAVEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET B (STV 0.2 0.1))
                )))
        ))

        ;; Buy FOOD
        (: Rule 7
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND ((PLANET A (STV 0.2 0.1)))))
                    (Action (SEQ_AND (BUY FOOD)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET A (STV 0.2 0.1))
                    (HAS FOOD (STV 0.2 0.1))
                )))
        ))

        ;; Buy Food in B
        (: Rule 8
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND ((PLANET B (STV 0.2 0.1)))))
                    (Action (SEQ_AND (BUY FOOD)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET B (STV 0.2 0.1))
                    (HAS FOOD (STV 0.2 0.1))
                )))
        ))

        ;; Buy food at C
        (: Rule 9
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND ((PLANET C (STV 0.2 0.1)))))
                    (Action (SEQ_AND (BUY FOOD)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET C (STV 0.2 0.1))
                    (HAS FOOD (STV 0.2 0.1))
                )))
        ))

        ;; Buy METAL at A
        (: Rule 10
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET A (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (BUY METAL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET A (STV 0.2 0.1))
                    (HAS METAL (STV 0.2 0.1))
                )))
        ))

        ;; Buy METAL at B
        (: Rule 11
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET B (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (BUY METAL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET B (STV 0.2 0.1))
                    (HAS METAL (STV 0.2 0.1))
                )))
        ))

        ;; Buy METAL at C
        (: Rule 12
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET C (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (BUY METAL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET C (STV 0.2 0.1))
                    (HAS METAL (STV 0.2 0.1))
                )))
        ))

        ;; Buy FUEL at A
        (: Rule 13
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET A (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (BUY FUEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET A (STV 0.2 0.1))
                    (HAS FUEL (STV 0.2 0.1))
                )))
        ))

        ;; Buy FUEL at B
        (: Rule 14
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET B (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (BUY FUEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET B (STV 0.2 0.1))
                    (HAS FUEL (STV 0.2 0.1))
                )))
        ))

        ;; Buy FUEL at C
        (: Rule 15
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET C (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND (BUY FUEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET C (STV 0.2 0.1))
                    (HAS FUEL (STV 0.2 0.1))
                )))
        ))

        ;; Sell FOOD at A
        (: Rule 16
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET A (STV 0.2 0.1))
                        (HAS FOOD (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL FOOD)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET A (STV 0.2 0.1))
                )))
        ))

        ;; Sell FOOD at B
        (: Rule 17
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET B (STV 0.2 0.1))
                        (HAS FOOD (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL FOOD)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET B (STV 0.2 0.1))
                )))
        ))

        ;; Sell FOOD at C
        (: Rule 18
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET C (STV 0.2 0.1))
                        (HAS FOOD (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL FOOD)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET C (STV 0.2 0.1))
                )))
        ))

        ;; Sell METAL at A
        (: Rule 19
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET A (STV 0.2 0.1))
                        (HAS METAL (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL METAL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET A (STV 0.2 0.1))
                )))
        ))

        ;; Sell METAL at B
        (: Rule 20
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET B (STV 0.2 0.1))
                        (HAS METAL (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL METAL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET B (STV 0.2 0.1))
                )))
        ))

        ;; Sell METAL at C
        (: Rule 21
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET C (STV 0.2 0.1))
                        (HAS METAL (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL METAL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET C (STV 0.2 0.1))
                )))
        ))

        ;; Sell FUEL at A
        (: Rule 22
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET A (STV 0.2 0.1))
                        (HAS FUEL (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL FUEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET A (STV 0.2 0.1))
                )))
        ))

        ;; Sell FUEL at B
        (: Rule 23
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET B (STV 0.2 0.1))
                        (HAS FUEL (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL FUEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET B (STV 0.2 0.1))
                )))
        ))

        ;; Sell FUEL at C
        (: Rule 24
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        (PLANET C (STV 0.2 0.1))
                        (HAS FUEL (STV 0.1 0.1))
                    )))
                    (Action (SEQ_AND (SELL FUEL)))
                )
                (Goal (STV 0.2 0.1) (AND (
                    (PLANET C (STV 0.2 0.1))
                )))
        )))
    ) (add-atom $space $rules)))

!(addWorldRules &worldSpace)

;;!(get-atoms &worldSpace)

;;!(updateMoney 400)
;;!(match &self (money $x) $x)


;;How can I build the main loop?
;;So the player knows the context he is in. 
;;What is the criteria of stopping? and what is the criteria of winining
;;Should we have maximum number of loops. This can be one of the stopping criteria.
;;The winning criteria is surpassing a threshold of money
;;The losing criteria having money zero or being on debt.

(= (gameLoop $contexts $money $ruleSpace $optimizer $numIter) 
    (if (>= $numIter 25)
        ("money:" $money "numIter:"  $numIter)
        (let* (
            ;; ($indices (probBasedSample $ruleSpace 10))
            ;; ($_ (println! (This are the indices $indices)))
            ;; ($sampledRules (collectRules $ruleSpace $indices ()))
            
            ($_ (println! (currMoney $money)))
            ($sampledRules (collapse (get-atoms $ruleSpace)))
            ($_ (add-atoms &cacheSpace $sampledRules))
            ($inferedRules (applyInference &cacheSpace))
            ($convertedRules (convertRulesToPSI $inferedRules))
            ($_ (println! (Im here $convertedRules)))
            ($_ (add-atoms $ruleSpace $convertedRules))
            ($_ (println! (Im here 2)))
            ($cachedValues (collapse (get-atoms &cacheSpace)))
            ($_ (remove-atoms &cacheSpace $cachedValues))
            ($_ (println! (Im here 3)))
            ($rules (collapse (get-atoms $ruleSpace)))
            ($_ (println! (Im here 4)))
            ;;($_ (println! (contexts $contexts money $money rules $rules)))
            ($_ (println! (contextForApplications $contexts)))
            ($applicableRules (getApplicableRules $contexts $money $rules))
            ($_ (println! (Im here 5)))
            ($_ (println! (applicableRules $applicableRules)))
            (($valueResult $selectedRule) ($optimizer $applicableRules))
            ($_ (println! (selectedRule $selectedRule)))
            (($newContexts $newMoney) (applyRule $selectedRule $contexts $money))
            ($_ (println! (context $newContexts newMoney $newMoney)))
            ($_ (println! (Im here 7)))
            ($oldStateValue (evaluateState $contexts $money))
            ($newStateValue (evaluateState $newContexts $newMoney))
            ($reward (- $newStateValue $oldStateValue))
            ($_ (println! (reward $reward)))
            ;; ($_ (updateRule $selectedRule $reward $ruleSpace))
            ($_ (println! (numberOfIterations $numIter)))
            ($newIter (+ $numIter 1))
        )
            ;   ;$newIter
            (gameLoop $newContexts $newMoney $ruleSpace $optimizer $newIter)
        )
    )
)


;;(= (reasoningSelector $context $goal $space $cacheSpace)
;;  (let* (
;;    ($indices (probBasedSample $space 5))
;;    ($sampledRules (collectRules $space $indices ()))
;;    ($_ (add-atoms $cacheSpace $sampledRules))
;;    ($inferedRules (applyInference $cacheSpace))
;;    ($convertedRules (convertRulesToPSI $inferedRules))
;;    ($_ (println! (converted Rules $convertedRules)))
;;    ($_ (add-atoms $space $convertedRules))
;;    ($_ (remove-atoms $cacheSpace))
;;    
;;  )
;;    (psiPlanner $context $goal $space)
;;  )
;;)


;;!(bind! &ruleSpace (new-space))
;;!(initializeSpace &ruleSpace)
!(gameLoop ((PLANET A)) 100 &worldSpace thompson-sample 0)
