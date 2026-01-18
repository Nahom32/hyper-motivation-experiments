(= (matchGoals $goals $rules) (
    if (== $rules ())
        ()
        (let* (
            (($rule $restRules) (decons-atom $rules))
            ($rule-goal (extractRule GoalValues $rule))
            ($restMatching (matchGoals $goals $restRules))
        ) (if (sameElements $goals $rule-goal)
            (cons-atom $rule $restMatching)
            $restMatching
        ))
))

(= (sameElements $list1 $list2) (
    if (not (== (size-atom $list1) (size-atom $list2)))
        False
        (let $intersection (intersection-atom $list1 $list2) (== (size-atom $intersection) (size-atom $list1)))      
))

(= (matchContexts $rules $contexts) (
    if (== $rules ())
        ()
        (let* (
            (($rule $restRules) (decons-atom $rules))
            ($rule-context (extractRule ContextValues $rule))
            ($restMatching (matchContexts $restRules $contexts))
        ) (if (sameElements $contexts $rule-context)
            (cons-atom $rule $restMatching)
            $restMatching
        ))
))

(= (thompsonSample $rules) (
    if (== $rules ())
        (-1 0) ; (Rule, Sampled Value)
    (let* (
        (($rule $rest) (decons-atom $rules))
        ($_ (println! ("Sampling rule: " $rule)))
        ((STV $strength $confidence) (extractRule STV $rule))
        ($_ (println! (Rule $strength $confidence)))
        (($alpha $beta) (stvToBeta ($strength $confidence)))
        ($sample (betaSample $alpha $beta))
        ($_ (println! ("Rule " $rule " gave sample: " $sample)))
        (($chosenId $chosenSample) (thompsonSample $rest))
    ) (if (>= $sample $chosenSample) 
        ($rule $sample) 
        ($chosenId $chosenSample)
    ))
))

;; For testing purposes, we simulate the result of performing actions
;; In a real implementation, this would interact with the environment
(= (performActions $actions) (
    let* (
        ($action-size (size-atom $actions))
        ($cutoff (div 1 (+ 1 $action-size)))
        ($_ (println! ("Action size: " $action-size " Cutoff: " $cutoff)))
        ($randomValue (/ (getRandom) 2))
        ($_ (println! ("Random Value: " $randomValue)))
    ) (if (< $randomValue $cutoff)
        1
        0
    )
))

(= (updateRule $rule $result $ruleSpace) (
    let* (
        ($_ (println! ("Updating rule: " $rule " with result: " $result)))
        ((STV $strength $confidence) (extractRule STV $rule))
        (($alpha $beta) (stvToBeta ($strength $confidence)))
        ($newAlpha (if (== $result 1) (+ $alpha 1) $alpha))
        ($newBeta (if (== $result 1) $beta (+ $beta 1)))
        (($newStrength $newConfidence) (betaToSTV ($newAlpha $newBeta)))
        ($_ (println! ("Old STV: " ($strength $confidence) " New STV: " ($newStrength $newConfidence))))
        ($_ (updateSTV $rule ($newStrength $newConfidence) $ruleSpace))
    ) ()
))

(: updateSTV (-> Number (Number Number) hyperon::space::DynSpace (->)))
(= (updateSTV $rule ($s $c) $space) (
    let* (
        ((: Rule $id $ttv (STV $os $oc) $comp $context $action $goal) $rule)
        ($newRule (: Rule $id $ttv (STV $s $c) $comp $impl))
        ($_ (updateAtom $space $rule $newRule))
    ) ()
))
