;;!(import! &self sampler)
!(import! &self rule-ops)
!(import! &self nars-util)
!(import! &self world_functions)
;;!(import! &self reasoning)
;;!(import! &self utils)

;; (= (Truth_c2w $c) (/ $c (- 1 $c)))
;; (= (Truth_w2c $w) (/ $w (+ $w 1)))
;; (= (Truth_Deduction ($f1 $c1) ($f2 $c2)) ((* $f1 $f2) (* (* $f1 $f2) (* $c1 $c2))))
;; (= (Truth_Abduction ($f1 $c1) ($f2 $c2)) ($f2 (Truth_w2c (* (* $f1 $c1) $c2))))
;; (= (Truth_Induction $T1 $T2) (Truth_Abduction $T2 $T1))
;; (= (Truth_Exemplification ($f1 $c1) ($f2 $c2)) (1.0 (Truth_w2c (* (* $f1 $f2) (* $c1 $c2)))))
;; ;;NAL-1
;; ;;!Syllogistic rules for Inheritance:
;; (= (reason (($a --> $b) $T1) (($b --> $c) $T2)) (($a --> $c) (Truth_Deduction $T1 $T2)))
;; (= (reason (($a --> $b) $T1) (($a --> $c) $T2)) (($c --> $b) (Truth_Induction $T1 $T2)))
;; (= (reason (($a --> $c) $T1) (($b --> $c) $T2)) (($b --> $a) (Truth_Abduction $T1 $T2)))
;; (= (reason (($a --> $b) $T1) (($b --> $c) $T2)) (($c --> $a) (Truth_Exemplification $T1 $T2)))
;; (= (reason (($a --> $b) $T1) (($c --> $d) $T2)) (if (== (intersection-atom ($a $b) ($c $d)) ()) () (empty)))
;; (= (reason (($a --> $b) $T1) (($a --> $b) $T1)) ())
;; Adopted from patrick's code.
(= (Truth_c2w $c) (/ $c (- 1 $c)))
(= (Truth_w2c $w) (/ $w (+ $w 1)))
(= (Truth_Deduction ($f1 $c1) ($f2 $c2)) ((* $f1 $f2) (* (* $f1 $f2) (* $c1 $c2))))
(= (Truth_Abduction ($f1 $c1) ($f2 $c2)) ($f2 (Truth_w2c (* (* $f1 $c1) $c2))))
(= (Truth_Induction $T1 $T2) (Truth_Abduction $T2 $T1))
(= (Truth_Exemplification ($f1 $c1) ($f2 $c2)) (1.0 (Truth_w2c (* (* $f1 $f2) (* $c1 $c2)))))

;;NAL-1
; deduction
(= (deductionResp ((($c1 $a1) --> $g1) $T1) ((($g1 $a2) --> $g2) $T2)) ((($c1 (union-atom $a1 $a2)) --> $g2) (Truth_Deduction $T1 $T2)))
(= (inductionResp ((($c1 $a1) --> $g1) $T1) ((($c1 $a1) --> $g2) $T2)) ((($g1 $a1) --> $g2) (Truth_Induction $T1 $T2)))
(= (abductionResp ((($c1 $a1) --> $g1) $T1) ((($c2 $a2) --> $g1) $T2)) ((($c1 $a1) --> $c2) (Truth_Abduction $T1 $T2)))
(= (exemplificationResp ((($c1 $a1) --> $g1) $T1) ((($g1 $a2) --> $g2) $T2)) ((($g2 (union-atom $a2 $a1)) --> $c2) (Truth_Exemplification $T1 $T2)))
(= (getMatchingPremises $type $premises $rule $remRules) 
    (let* (
        ($ruleGoal (extractRule GoalValues $rule))
        ($_ (println! ("Rule Goal: " $ruleGoal)))
        ($ruleContextAction (extractRule ContextAndAction $rule))
        ($_ (println! ("Rule Context and Action: " $ruleContextAction)))
        ($_ (println! ("Remaining Rules: " (collapse (get-atoms &ruleSpace)))))
        ($matchingRules (case $type (
            (abduction (eval (filter-rules-by-goal $ruleGoal $remRules)))
            (deduction (eval (filter-rules-by-context $ruleGoal $remRules)))
            (induction (eval (filter-rules-by-antecedent $ruleContextAction $remRules)))
            (exemplification (eval (filter-rules-by-context $ruleGoal $remRules)))
            ($default ())
        )))
        ($_ (println! ("Matching Rules: " (size-atom $matchingRules))))
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

(= (convertRuleToPSI $rule)
    (let* (
        ($id (random-int 100 500)) ;; temporary ID generation
        ; ($_ (println! ("Converting rule to Narsese with ID: " $id " and rule: " $rule)))
        (((($context $action) --> $goal) ($freq $conf)) $rule)
        ($lbConf (max 0.01 $conf)) ;; due to arthmetic issues, I set a lower bound for confidence
        

        ($complexity (size-atom $action))
    )
      (: Rule $id 
        (TTV 0)
        (STV $freq $lbConf)
        (Complexity $complexity)
        (IMPLICATION 
            (AND 
                (Context 
                    (STV 0.2 0.1) 
                    (AND $context)
                )
                (Action (SEQ_AND $action)))
            (Goal 
                (STV 0.2 0.1) 
                (AND $goal)
            )
        )))
)

(= (convertRulesToPSI $rules) (collapse (convertRuleToPSI (superpose $rules))))


;; Description
;; Changes these rules to nars representation (narsese)
(= (convertRuleToNars $rule) 
    (let* (
      ($context (eval (extractRule Context $rule)))
      ($action (eval (extractRule Action $rule)))
      ($goal (eval (extractRule Goal $rule)))
      ($STV (eval (extractRule STV $rule)))
      ((STV $freq $conf) $STV)

      ($id (eval (extractRule Id $rule)))
    )
      ($id ((($context $action) --> $goal) ($freq $conf))) 
    )
)

(= (getPlanetFromContexts $contexts) (
    let* (
        (($head $tail) (decons-atom $contexts))
        ($_ (println! (contexts $contexts)))
        (($data $stv) $head)
        ($contextType (index-atom $data 0))
        ($contextValue (index-atom $data 1))
    ) (if (== $contextType PLANET)
        $contextValue
        (getPlanetFromContexts $tail)
    ))
)
(= (applyDeduction $rules) (
    if (<= (size-atom $rules) 1)
        ()
        (let* (
            (($rule $remRules) (decons-atom $rules))
            ($premise-one (eval (extractRule ContextSTV $rule)))
            ($premise-two (eval (extractRule GoalSTV $rule)))
            ($premise-four (eval (extractRule STV $rule)))
            ($premises ($premise-one $premise-two $premise-four))
            ($_ (println! (premises $premises)))
            ($matchingRuleDeductions (getMatchingPremises deduction $premises $rule $remRules))
            ($restDeductions (applyDeduction $remRules))
        ) (union-atom $restDeductions $matchingRuleDeductions))
))

(= (reason-ded $rule $matchingRule $premises) (
    let* (
        (($id1 $narsRule) (convertRuleToNars $rule))
        (($id2 $narsMatchingRule) (convertRuleToNars $matchingRule))
         ($_ (println! ("Reasoning with rule: " $narsRule)))
        ($_ (println! ("Reasoning with matching rule: " $narsMatchingRule)))
        ($inferenceResult (eval (deductionResp $narsRule $narsMatchingRule)))
        ($_ (println! ("Inference result: " $inferenceResult)))
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
            ($_ (println! (premises $premises)))
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
            ($_ (println! (premises $premises)))
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

(= (nars-reasoning $rules) (
    let* (
        ($deductions (applyDeduction $rules))
        ($inductions (applyInduction $rules))
        ($abductions (applyAbduction $rules))
    )
    (union-atom $deductions (union-atom $inductions $abductions))
))
; Exemplification Truth is hard to justify it with Context & Action schema
(= (reason $R1 $R2) (empty))

(= (complexity $rule)
    (let* (
        (($id $mainRule) $rule)
        ($_ (println! (The id $id)))
        (((($context $action) --> $goal) $tv) $mainRule)
    )
      (size-atom $action)
    )
)

;;!(complexity (3 (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1)))) (0.5 0.002))))


(= (convertRuleToPSI $rule)
    (if (== $rule ()) ()
    (let* (
      (($id (($precedent --> $antecedent) ($freq $conf))) $rule)
      ($complexity (size-atom $antecedent))
      ($truthValue (STV $freq $conf)) 
      (($context $action) $precedent)
      ($goal $antecedent)

    )
      (: Rule $id 
        (TTV 0)
        $truthValue
        (Complexity $complexity)
        (IMPLICATION (AND $context $action) $goal)
      )
      
    )
    )
)
(= (convertRulesToPSI $rules) (collapse (convertRuleToPSI (superpose $rules))))
(= (addRules $space) 
    (let $rules (superpose (
    ;; Rule 1
    (: Rule 1
        (TTV 0)
        (STV 0.5 0.002)  
        (Complexity 1)
        (IMPLICATION
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (LEFT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_AND (MOVE_RIGHT))))
            (Goal (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))
        )) 
    ))

    ;; Rule 3
    (: Rule 3
        (TTV 0)
        (STV 0.5 0.002)  
        (Complexity 1)
        (IMPLICATION 
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (LEFT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_AND (MOVE_RIGHT))))
            (Goal (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (DEAD (STV 0.2 0.1)))
        )) 
    ))

    ;; Rule 2
    (: Rule 2
        (TTV 0)
        (STV 0.5 0.002)  
        (Complexity 1)
        (IMPLICATION 
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_AND (MOVE_RIGHT)) ) )
            (Goal (STV 0.2 0.1) (AND (
                    (RIGHT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))
        )) 
    ))

    ;; Rule 4
    (: Rule 4
        (TTV 0)
        (STV 0.7 0.62)  
        (Complexity 1)
        (IMPLICATION 
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (LEFT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_AND (JUMP_RIGHT)) ) )
            (Goal (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))
        )) 
    ))
)) (add-atom $space $rules) ))



;;!(addRules &rulespace)


(= (add-atoms $space $values)
  (if (== $values ()) () 
      (let* (
          ($head (car-atom $values))
          ($tail (cdr-atom $values))
          ($_ (add-atom $space $head))
      )
        (add-atoms $space $tail)

      )
  )
)
(= (remove-atoms $space $values)
    (if (== $values ())
        ()
        (let* (
            ($head (car-atom $values))
            ($tail (cdr-atom $values))
            ($_ (remove-atom $space $head))
        )
          (remove-atoms $space $tail)
        )
    )
)

;; Description
;; Changes these rules to nars representation (narsese)
;; (= (convertRuleToNars $rule) 
;;     (let* (
;;       ($context (eval (extractRule Context $rule)))
;;       ($action (eval (extractRule Action $rule)))
;;       ($goal (eval (extractRule Goal $rule)))
;;       ($STV (eval (extractRule STV $rule)))
;;       ((STV $freq $conf) $STV)

;;       ($id (eval (extractRule Id $rule)))
;;     )
;;       ($id ((($context $action) --> $goal) ($freq $conf))) 
;;     )
;; )


;; (= (|- $rule1 $rule2)
;;     (let* (
;;         (($id1 $narsRule1) $rule1)
;;         ($_ (println! (narsRule1 $narsRule1)))
;;         (($id2 $narsRule2) $rule2)
;;         ($_ (println! (narsRule2 $narsRule2)))
;;         ($result (reason $narsRule1 $narsRule2))
;;         ($_ (println! (resultInference $result)))
;;       )
;;        (reason $narsRule1 $narsRule2) 
;;     )
;; )


;; (= (isReduced $value) (if (== $value ()) false true))
;; (= (applyInferenceForRule $rule $rules $accum)
;;   (if (== $rules ())
;;      $accum
;;     (let* (
;;         (($head $tail) (decons-atom $rules))
;;         ($_ (println! (forApplication $rule space $head)))
;;         ($result (|- $rule $head))
;;         ($_ (println! (results $result)))
;;         ($reduced (isReduced $result))
;;         ($_ (println! (reduced $reduced)))
;;         ($accum' (if (not $reduced) $accum (union-atom $accum ($result))))
;;     ) 
;;       (applyInferenceForRule $rule $tail  $accum')
;;   )
;; )
;; )

;; (= (applyInference' $rules  $accum)
;;   (if (== $rules ())
;;      $accum
;;     (let* (
;;       (($head $tail) (decons-atom $rules))
;;       ($_ (println! (decons-result $head $tail)))
;;       ($inferedRules (applyInferenceForRule $head $tail ()))
;;       ($_ (println! (inferedRules $inferedRules)))
;;       ;;($ruleSize (size-atom $inferedRules))
;;       ($accum' (union-atom $accum $inferedRules))
;;     )
;;      (applyInference' $tail  $accum')
;;     )
;;   )
;; )

;; (= (applyInference $space)
;;   (let* (
;;     ($rules (collapse (get-atoms $space)))
;;     ($narsRules (collapse (convertRuleToNars (superpose $rules))))
;;     ($_ (println! (narsRules $narsRules)))
;;     ($newRules (applyInference' $narsRules ()))
        
;;   )
;;     $newRules
;;   )
;; )

(= (applyInference $space)
    (let* (
      ($rules (collapse (get-atoms $space)))
      ($_ (println! (rulesForInference $rules)))
      ($newRules (nars-reasoning $rules))
    )
      $newRules
    )
)
(= (matchContextRules $rules $contexts) (
    if (== $rules ())
        ()
        (let* (
            (($rule $restRules) (decons-atom $rules))
            ($_ (println! (dec $rule)))
            ($rule-context (extractRule ContextValues $rule))
            ($restMatching (matchContextRules $restRules $contexts))
        ) (if (sameElements $contexts $rule-context)
            (cons-atom $rule $restMatching)
            $restMatching
        ))
))


(= (psiPlanner $contexts $goals $ruleSpace) (
    let* (
        ($_ (println! (Current Values: Contexts: $contexts Goals: $goals)))
        ($rules (collapse (get-atoms $ruleSpace)))
        ($matchingGoals (matchGoals $goals $rules))
        ($_ (println! (Matched Goals:  $matchingGoals)))
        ($matchingContexts (matchContextRules $matchingGoals $contexts))
        ($_ (println! (Matched Contexts:  $matchingContexts)))
        ($applicableRules $matchingContexts)
        ($_ (println! (Applicable Rules:  (size-atom $applicableRules))))
        (($sampledRule $sampledValue) (thompsonSample $applicableRules))
        ($_ (println! (Sampled Rule ID:  $sampledRule)))
        ($actions (extractRule Action $sampledRule))
        ($_ (println! (Performing Actions:  $actions)))
        ($result (performActions $actions))
        ($_ (println! (Resulting State:  $result)))
        ($updatedRule (updateRule $sampledRule $result $ruleSpace))
    ) ()
))

(= (reasoningSelector $context $goal $space $cacheSpace)
  (let* (
    ($indices (probBasedSample $space 5))
    ($sampledRules (collectRules $space $indices ()))
    ($_ (add-atoms $cacheSpace $sampledRules))
    ($inferedRules (applyInference $cacheSpace))
    ($convertedRules (convertRulesToPSI $inferedRules))
    ($_ (println! (converted Rules $convertedRules)))
    ($_ (add-atoms $space $convertedRules))
    ($_ (remove-atoms $cacheSpace))
    
  )
    (psiPlanner $context $goal $space)
  )
)


(= (isValidRule $contexts $money $rule) (
    let* (
        ($ruleContext (eval (extractRule ContextValues $rule)))
        ($_ (println! (isVal ruleContext $ruleContext)))
        ($ruleActions (eval (extractRule Action $rule)))
        ($currPlanet (getPlanetFromContexts $contexts))
        ($rulePlanet (getPlanetFromContexts $ruleContext))
        ($_ (println! ("curr planet:" $currPlanet "rule planet: " $rulePlanet)))
    ) 
    (if (not (== $currPlanet $rulePlanet)) 
        False
        (isValidActions $rule $ruleActions $contexts $money)
    )
))

(= (isValidActions $rule $actions $contexts $money) (
    if (== $actions ())
        True
        (let* (
            (($head $tail) (decons-atom $actions))
            ($isValid (isValidSingleAction $rule $head $contexts $money))
            (($newContexts $newMoney) (applySingleAction $rule $head $contexts $money))
            ($isValid2 (if $isValid (isValidActions $rule $tail $newContexts $newMoney) False))
        ) $isValid2
              
        )
))
(= (applySingleAction $rule $action $contexts $money) (
    let* (
        ($actionType (index-atom $action 0))
        ; ($_ (println! ("Action Type" $actionType)))
    ) (case $actionType (
        (TRAVEL (applyTravel $rule $contexts $money))
        (SELL (applySell $rule $contexts $money))
        (BUY (applyBuy $rule $contexts $money))
    ))
))

(= (isValidSingleAction $rule $action $contexts $money) (
    let* (
        ($actionType (index-atom $action 0))
        ($_ (println! (actionType $actionType)))
        ($currPlanet (getPlanetFromContexts $contexts))
    ) (case $actionType (
            (TRAVEL (
                let* (
                    ($cost 1)
                    ($_ (println! (cost $cost)))
                ) (if (> $cost $money)
                    False
                    True
                )
            ))

            (SELL (
                let* (
                    ($item (index-atom $action 1))
                    (($foundName $stv) (getItem $contexts $item))
                ) (if (== $item $foundName)
                    True
                    False
                )
            ))

            (BUY (
                let* (
                    ($item (index-atom $action 1))
                    ($itemPrice (eval (getItemPrice $item $currPlanet)))
                ) (if (>= $money $itemPrice ) 
                    True
                    False
                )
            ))
    ))
))
(= (getApplicableRules $contexts $money $rules) (
    if (== () $rules)
        ()
        (let* (
            (($head $tail) (decons-atom $rules))
            ($_ (println! (applicableContexts $contexts)))
            ($isValid (isValidRule $contexts $money $head))
            ($_ (println! (isValid $isValid)))
            ($rest (getApplicableRules $contexts $money $tail))
            ($_ (println! (rest $rest)))
        ) (if $isValid
            (cons-atom $head $rest)
            $rest
        ))
))

(= (updatePlanet $contexts $planet) (
    if (== $contexts ())
        ()
        (let* (
            (($head $tail) (decons-atom $contexts))
            ($_ (println! (planet $head)))
            ($contextType (index-atom $head 0))
            ($contextValue (index-atom $head 1))
            ($rest (updatePlanet $tail $planet))
            ($_ (println! (rest $rest)))
        ) (if (== $contextType PLANET)
            (cons-atom (PLANET $planet) $rest)
            (cons-atom $head $rest)
        )))
)

(= (addItem $contexts $item) (
    if (== $contexts ())
        (cons-atom (HAS $item) ())
        (let* (
            (($head $tail) (decons-atom $contexts))
            ($contextType (index-atom $head 0))
            ($contextValue (index-atom $head 1))
            ($rest (addItem $tail $item))
        ) (if (== $contextType HAS)
            $rest
            (cons-atom $head $rest)
        ))
))

(= (removeItem $contexts $item) (
    if (== $contexts ())
        ()
        (let* (
            (($head $tail) (decons-atom $contexts))
            ($contextType (index-atom $head 0))
            ($contextValue (index-atom $head 1))
            ($rest (removeItem $tail $item))
        ) (if (== $contextValue $item)
            $rest
            (cons-atom $head $rest)
        ))
))

(= (applyTravel $rule $contexts $money) (
    let* (
        ($_ (println! (TRAVEL BEING APPLIED)))
        ($ruleContext (extractRule ContextValues $rule))
        ($_ (println! (ruleContextTravel $ruleContext)))
        ($ruleGoal (extractRule GoalValues $rule))
        ($source (getPlanetFromContexts $ruleContext))
        ($_ (println! (sourceTravel $source)))
        ($destination (getPlanetFromContexts $ruleGoal))
        ($_ (println! (destinationTravel $destination)))
        ($cost (getTravelCost $source $destination))
        ($_ (println! (costTravel $cost)))
        ($newContext (updatePlanet $contexts $destination)) ;; TODO
        ($newMoney (- $money $cost))
    ) ($newContext $newMoney)
))

(= (applySell $rule $contexts $money) (
    let* (
        ($item (getItem $contexts))
        ($planet (getPlanetFromContexts $contexts))
        ($_ (println! (planetSell $planet)))
        ($newContext (removeItem $contexts $item))
        ($newMoney (+ $money (getItemPrice $item $planet)))
    ) ($newContext $newMoney)
))

(= (applyBuy $rule $contexts $money) (
    let* (
        ($ruleGoal (extractRule GoalValues $rule))
        ($item (getItem $ruleGoal))
        ($planet (getPlanetFromContexts $ruleGoal))
        ($itemPrice (getItemPrice $item $planet))
        ($newContext (addItem $contexts $item))
        ($newMoney (- $money $itemPrice))
    ) ($newContext $newMoney)
))

(= (applyRule $rule $contexts $money) (
    let* (
        ($ruleActions (extractRule Action $rule))
        ($_ (println! (ruleActions $ruleActions)))
        ($ruleAction (index-atom $ruleActions 0))
        ($_ (println! (ruleAction $ruleAction)))
    ) (case $ruleAction (
        (TRAVEL (applyTravel $rule $contexts $money))
        (SELL (applySell $rule $contexts $money))
        (BUY (applyBuy $rule $contexts $money))
    ))
))

(= (getItem $contexts) (
    if (== $contexts ())
        ()
        (let* (
            ($_ (println! (itemContext $contexts)))
            (($head $tail) (decons-atom $contexts))
            ($contextType (index-atom $head 0))
            ($_ (println! (headItem $head)))
            ($itemName (index-atom $head 1))
            ($_ (println! (gItem $itemName)))
        ) (if (== $contextType HAS)
            $itemName
            (getItem $tail)
        ))
))

(= (evaluateState $contexts $money) (
    let* (
        ($_ (println! (stateContexts $contexts)))
        ($item (getItem $contexts))
        ($_ (println! (stateItem $item)))
        ($itemValue (getAvgPrice $item))
        ($_ (evalStateValue $itemValue))
    ) (+ $itemValue $money)
))

(= (updateBeta $alpha $beta $reward) (
    if (== $reward 0) 
        ((+ 1 $alpha) (+ 1 $beta))
        (if (> $reward 0)
            ((+ $alpha $reward) $beta)
            ($alpha (+ $beta $reward))
        )
))

(= (updateSTV $rule ($strength $confidence)) (
    let* (
        ((: Rule $id $ttv (STV $s $c) $comp $impl) $rule)
    ) (: Rule $id $ttv (STV $strength $confidence) $comp $impl)
))

(= (updateRule $selectedRule $reward) (
    let* (
        ((STV $s $c) (extractRule STV $selectedRule))
        (($alpha $beta) (stvToBeta ($s $c)))
        (($newAlpha $newBeta) (updateBeta $alpha $beta $reward))
        (($newStrength $newConfidence) (betaToSTV $newAlpha $newBeta))
        ($newRule (updateSTV $selectedRule ($newStrength $newConfidence)))
    ) $newRule
))
;;!(intersection-atom ((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) ( (((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1))))) 
;;(((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002))
;;!(match &self (($a --> $b) $c) $c)
;;!(let (($A --> $B) $stv) (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002)) $A)
;;!(reason (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002)) 
;;          (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1)))) (STV 0.5 0.002)))
;;!(applyInference &rulespace)
;;!(reasoningSelector (LEFT_SQUARE STILL_ALIVE) (CENTER_SQUARE STILL_ALIVE) &rulespace &cachespace)


;;!(convertRuleToPSI (1 (((((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((RIGHT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (0.5 0.002))))

