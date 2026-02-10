(= (getMatchingPremises $type $premises $rule $remRules) (
    let* (
        ($ruleGoal (extractRule GoalValues $rule))
        ; ($_ (println! ("Rule Goal: " $ruleGoal)))
        ($ruleContextAction (extractRule ContextAndAction $rule))
        ; ($_ (println! ("Rule Context and Action: " $ruleContextAction)))
        ; ($_ (println! ("Remaining Rules: " (collapse (get-atoms &ruleSpace)))))
        ($matchingRules (case $type (
            (abduction (eval (filter-rules-by-goal $ruleGoal $remRules)))
            (deduction (eval (filter-rules-by-context $ruleGoal $remRules)))
            (induction (eval (filter-rules-by-antecedent $ruleContextAction $remRules)))
            (exemplification (eval (filter-rules-by-context $ruleGoal $remRules)))
            ($default ())
        )))
        ; ($_ (println! ("Matching Rules: " (size-atom $matchingRules))))
    ) (
        if (== $type deduction)
            (map-atom $matchingRules $matchingRule (reason-ded $rule $matchingRule $premises))
            (if (== $type abduction)
                (map-atom $matchingRules $matchingRule (reason-abd $rule $matchingRule $premises))
                (if (== $type induction)
                    (map-atom $matchingRules $matchingRule (reason-ind $rule $matchingRule $premises))
                    (if (== $type exemplification)
                        (map-atom $matchingRules $matchingRule (reason-exe $rule $matchingRule $premises))
                        (empty)
                    )
                ))
    )
))


(= (applyDeduction $rules) (
    if (<= (size-atom $rules) 1)
        ()
        (let* (
            (($rule $remRules) (decons-atom $rules))
            ($premise-one (eval (extractRule ContextSTV $rule)))
            ($premise-two (eval (extractRule GoalSTV $rule)))
            ($premise-four (eval (extractRule STV $rule)))
            ($premises ($premise-one $premise-two $premise-four))
            ($matchingRuleDeductions (getMatchingPremises deduction $premises $rule $remRules))
            ($restDeductions (applyDeduction $remRules))
        ) (union-atom $restDeductions $matchingRuleDeductions))
))

(= (reason-ded $rule $matchingRule $premises) (
    let* (
        (($id1 $narsRule) (convertRuleToNars $rule))
        (($id2 $narsMatchingRule) (convertRuleToNars $matchingRule))
        ; ($_ (println! ("Reasoning with rule: " $narsRule)))
        ; ($_ (println! ("Reasoning with matching rule: " $narsMatchingRule)))
        ($inferenceResult (eval (deductionResp $narsRule $narsMatchingRule)))
        ; ($_ (println! ("Inference result: " $inferenceResult)))
    ) (convertRuleToPSI $inferenceResult)
))


(= (reason-abd $rule $matchingRule $premises) (
    let* (
        (($id1 $narsRule) (convertRuleToNars $rule))
        (($id2 $narsMatchingRule) (convertRuleToNars $matchingRule))
        ($inferenceResult (eval (abductionResp $narsRule $narsMatchingRule)))
    ) (convertRuleToPSI $inferenceResult)
))


(= (reason-ind $rule $matchingRule $premises) (
    let* (
        (($id1 $narsRule) (convertRuleToNars $rule))
        (($id2 $narsMatchingRule) (convertRuleToNars $matchingRule))
        ($inferenceResult (eval (inductionResp $narsRule $narsMatchingRule)))
    ) (convertRuleToPSI $inferenceResult)
))


(= (reason-exe $rule $matchingRule $premises) (
    let* (
        (($id1 $narsRule) (convertRuleToNars $rule))
        (($id2 $narsMatchingRule) (convertRuleToNars $matchingRule))
        ($inferenceResult (eval (exemplificationResp $narsRule $narsMatchingRule)))
    ) (convertRuleToPSI $inferenceResult)
))


(= (applyInduction $rules) (
    if (<= (size-atom $rules) 1)
        ()
        (let* (
            (($rule $remRules) (decons-atom $rules))
            ($premise-one (eval (extractRule ContextSTV $rule)))
            ($premise-two (eval (extractRule GoalSTV $rule)))
            ($premise-four (eval (extractRule STV $rule)))
            ($premises ($premise-one $premise-two $premise-four))
            ($matchingRuleInductions (eval (getMatchingPremises induction $premises $rule $remRules)))
            ($restInductions (applyInduction $remRules))
        ) (union-atom $restInductions $matchingRuleInductions))
))


(= (applyAbduction $rules) (
    if (<= (size-atom $rules) 1)
        ()
        (let* (
            (($rule $remRules) (decons-atom $rules))
            ($premise-one (eval (extractRule ContextSTV $rule)))
            ($premise-two (eval (extractRule GoalSTV $rule)))
            ($premise-four (eval (extractRule STV $rule)))
            ($premises ($premise-one $premise-two $premise-four))
            ($matchingRuleAbductions (eval (getMatchingPremises abduction $premises $rule $remRules)))
            ($restAbductions (applyAbduction $remRules))
        ) (union-atom $restAbductions $matchingRuleAbductions))
))

(= (applyExemplification $rules) (
    if (<= (size-atom $rules) 1)
        ()
        (let* (
            (($rule $remRules) (decons-atom $rules))
            ($premise-one (eval (extractRule ContextSTV $rule)))
            ($premise-two (eval (extractRule GoalSTV $rule)))
            ($premise-four (eval (extractRule STV $rule)))
            ($premises ($premise-one $premise-two $premise-four))
            ($matchingRuleExemplifications (eval (getMatchingPremises exemplification $premises $rule $remRules)))
            ($restExemplifications (applyExemplification $remRules))
        ) (union-atom $restExemplifications $matchingRuleExemplifications))
))