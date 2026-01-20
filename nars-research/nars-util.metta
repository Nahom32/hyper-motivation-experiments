
;;!(import! &self utils)

;;(: countSimilar (-> Expression Expression Number))
;;(= (countSimilar $listOne $listTwo) (
;;    let* (
;;        ($count (collapse (let $value (superpose $listOne) (let $isIn (isMember $listTwo $value) $isIn))))
;;    ) (sum $count)
;;))
;;
;;(= (areSimilar $listOne $listTwo) 
;;    (if (not (== (size-atom $listOne) (size-atom $listTwo)))
;;        False
;;        (if (== (size-atom $listOne) (countSimilar $listOne $listTwo))
;;            True 
;;            False)
;;))
;;
;;
;;(: min (-> Number Number Number))
;;(= (min $num1 $num2) (
;;    if (< $num1 $num2)
;;        $num1
;;        $num2
;;))
;;
;;(: div (-> Number Number Number))
;;(= (div $num $denom) (
;;    (py-atom operator.truediv) $num $denom
;;))

;;(: round (-> Number Number Number))
(= (round $num $sig) ((py-atom round) $num $sig))
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
        ($cutoff (/ 1.0 (+ 1 $action-size)))
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

;;(: updateSTV (-> Number (Number Number) hyperon::space::DynSpace (->)))
(= (updateSTV $rule ($s $c) $space) (
    let* (
        ((: Rule $id $ttv (STV $os $oc) $comp $context $action $goal) $rule)
        ($newRule (: Rule $id $ttv (STV $s $c) $comp $impl))
        ($_ (updateAtom $space $rule $newRule))
    ) ()
))
