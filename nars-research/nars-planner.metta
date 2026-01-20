!(import! &self sampler)
!(import! &self rule-ops)
!(import! &self nars-util)

(= (Truth_c2w $c) (/ $c (- 1 $c)))
(= (Truth_w2c $w) (/ $w (+ $w 1)))
(= (Truth_Deduction ($f1 $c1) ($f2 $c2)) ((* $f1 $f2) (* (* $f1 $f2) (* $c1 $c2))))
(= (Truth_Abduction ($f1 $c1) ($f2 $c2)) ($f2 (Truth_w2c (* (* $f1 $c1) $c2))))
(= (Truth_Induction $T1 $T2) (Truth_Abduction $T2 $T1))
(= (Truth_Exemplification ($f1 $c1) ($f2 $c2)) (1.0 (Truth_w2c (* (* $f1 $f2) (* $c1 $c2)))))
;;NAL-1
;;!Syllogistic rules for Inheritance:
(= (reason (($a --> $b) $T1) (($b --> $c) $T2)) (($a --> $c) (Truth_Deduction $T1 $T2)))
(= (reason (($a --> $b) $T1) (($a --> $c) $T2)) (($c --> $b) (Truth_Induction $T1 $T2)))
(= (reason (($a --> $c) $T1) (($b --> $c) $T2)) (($b --> $a) (Truth_Abduction $T1 $T2)))
(= (reason (($a --> $b) $T1) (($b --> $c) $T2)) (($c --> $a) (Truth_Exemplification $T1 $T2)))
(= (reason (($a --> $b) $T1) (($c --> $d) $T2)) (if (== (intersection-atom ($a $b) ($c $d)) ()) () (empty)))
(= (reason (($a --> $b) $T1) (($a --> $b) $T1)) ())


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

;;(= (addRules $space)
;;    (let $rules (superpose 
;;  (
;;    (: Rule 1
;;      (TTV 0)
;;      (STV 0.6 0.01)
;;      (Complexity 2)
;;      (IMPLICATION
;;          (AND
;;              (Context (STV 0.4 0.1)
;;                  (AND
;;                      (HAS_CAPITAL (STV 0.5 0.1))
;;                      (PRICE_LOW (STV 0.6 0.1) (COMMODITY_A))
;;                      (SYSTEM_VISITED (STV 0.4 0.1))
;;                  ))
;;              (Action
;;                  (SEQ_AND
;;                      (BUY (COMMODITY_A))
;;                  ))
;;          )
;;          (Goal (STV 0.5 0.1)
;;              (AND
;;                  (INVENTORY_INCREASED (STV 0.5 0.1))
;;                  (PROFIT_POTENTIAL (STV 0.6 0.1))
;;              ))
;;      )
;;  )
;;
;;  (: Rule 2
;;      (TTV 0)
;;      (STV 0.7 0.02)
;;      (Complexity 3)
;;      (IMPLICATION
;;          (AND
;;              (Context (STV 0.5 0.1)
;;                  (AND
;;                      (EVENT_ACTIVE (STV 0.6 0.1) (FAMINE))
;;                      (COMMODITY_TYPE (STV 0.5 0.1) (FOOD))
;;                      (INVENTORY_AVAILABLE (STV 0.4 0.1))
;;                  ))
;;              (Action
;;                  (SEQ_AND
;;                      (TRAVEL_TO (AFFECTED_SYSTEM))
;;                      (SELL (FOOD))
;;                  ))
;;          )
;;          (Goal (STV 0.7 0.1)
;;              (AND
;;                  (PROFIT_REALIZED (STV 0.7 0.1))
;;                  (CAPITAL_INCREASED (STV 0.6 0.1))
;;              ))
;;      )
;;  )
;;
;;  (: Rule 3
;;      (TTV 0)
;;      (STV 0.65 0.015)
;;      (Complexity 4)
;;      (IMPLICATION
;;          (AND
;;              (Context (STV 0.4 0.1)
;;                  (AND
;;                      (KNOWS_PRODUCTION_CHAIN (STV 0.6 0.1))
;;                      (ROUTE_AVAILABLE (STV 0.5 0.1))
;;                      (FUEL_SUFFICIENT (STV 0.4 0.1))
;;                  ))
;;              (Action
;;                  (SEQ_AND
;;                      (BUY (RAW_MATERIAL))
;;                      (TRAVEL_TO (INDUSTRIAL_SYSTEM))
;;                      (SELL (RAW_MATERIAL))
;;                      (BUY (REFINED_GOODS))
;;                  ))
;;          )
;;          (Goal (STV 0.6 0.1)
;;              (AND
;;                  (TRADE_CYCLE_COMPLETED (STV 0.5 0.1))
;;                  (LONG_TERM_PROFIT (STV 0.6 0.1))
;;              ))
;;      )
;;  )
;;
;;  (: Rule 4
;;      (TTV 0)
;;      (STV 0.55 0.02)
;;      (Complexity 3)
;;      (IMPLICATION
;;          (AND
;;              (Context (STV 0.5 0.1)
;;                  (AND
;;                      (EVENT_ACTIVE (STV 0.6 0.1) (UNREST))
;;                      (RISK_LEVEL_HIGH (STV 0.5 0.1))
;;                      (CAPITAL_LOW (STV 0.4 0.1))
;;                  ))
;;              (Action
;;                  (SEQ_AND
;;                      (AVOID_SYSTEM)
;;                  ))
;;          )
;;          (Goal (STV 0.5 0.1)
;;              (AND
;;                  (CAPITAL_PRESERVED (STV 0.5 0.1))
;;                  (LOSS_AVOIDED (STV 0.6 0.1))
;;              ))
;;      )
;;  )
;;
;;  (: Rule 5
;;      (TTV 0)
;;      (STV 0.6 0.02)
;;      (Complexity 5)
;;      (IMPLICATION
;;          (AND
;;              (Context (STV 0.5 0.1)
;;                  (AND
;;                      (PERFORMANCE_EVALUATED (STV 0.6 0.1))
;;                      (PROFIT_TREND_DOWN (STV 0.5 0.1))
;;                      (STRATEGY_ACTIVE (STV 0.4 0.1))
;;                  ))
;;              (Action
;;                  (SEQ_AND
;;                      (UPDATE_RISK_PROFILE)
;;                      (REFINE_TRADING_RULES)
;;                  ))
;;          )
;;          (Goal (STV 0.6 0.1)
;;              (AND
;;                  (STRATEGY_ADAPTED (STV 0.6 0.1))
;;                  (EXPECTED_PROFIT_INCREASED (STV 0.5 0.1))
;;              ))
;;      )
;;  )
;;
;;  (: Rule 6
;;      (TTV 0)
;;      (STV 0.58 0.015)
;;      (Complexity 3)
;;      (IMPLICATION
;;          (AND
;;              (Context (STV 0.4 0.1)
;;                  (AND
;;                      (MULTIPLE_ROUTES_AVAILABLE (STV 0.5 0.1))
;;                      (TRAVEL_COST_HIGH (STV 0.4 0.1))
;;                  ))
;;              (Action
;;                  (SEQ_AND
;;                      (SELECT_OPTIMAL_ROUTE)
;;                  ))
;;          )
;;          (Goal (STV 0.5 0.1)
;;              (AND
;;                  (TRAVEL_COST_REDUCED (STV 0.5 0.1))
;;                  (NET_PROFIT_IMPROVED (STV 0.6 0.1))
;;              ))
;;      )
;;  )
;;
;;)
;;) (add-atom $space $rules)))

;; What if I use the following format ($id $rule-narsese)

!(addRules &rulespace)


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


(= (|- $rule1 $rule2)
    (let* (
        (($id1 $narsRule1) $rule1)
        ($_ (println! (narsRule1 $narsRule1)))
        (($id2 $narsRule2) $rule2)
        ($_ (println! (narsRule2 $narsRule2)))
        ($result (reason $narsRule1 $narsRule2))
        ($_ (println! (resultInference $result)))
      )
       (reason $narsRule1 $narsRule2) 
    )
)


(= (isReduced $value) (if (== $value ()) false true))
(= (applyInferenceForRule $rule $rules $accum)
  (if (== $rules ())
     $accum
    (let* (
        (($head $tail) (decons-atom $rules))
        ($_ (println! (forApplication $rule space $head)))
        ($result (|- $rule $head))
        ($_ (println! (results $result)))
        ($reduced (isReduced $result))
        ($_ (println! (reduced $reduced)))
        ($accum' (if (not $reduced) $accum (union-atom $accum ($result))))
    ) 
      (applyInferenceForRule $rule $tail  $accum')
  )
)
)

(= (applyInference' $rules  $accum)
  (if (== $rules ())
     $accum
    (let* (
      (($head $tail) (decons-atom $rules))
      ($_ (println! (decons-result $head $tail)))
      ($inferedRules (applyInferenceForRule $head $tail ()))
      ($_ (println! (inferedRules $inferedRules)))
      ($ruleSize (size-atom $inferedRules))
      ($accum' (union-atom $accum $inferedRules))
    )
     (applyInference' $tail  $accum')
    )
  )
)

(= (applyInference $space)
  (let* (
    ($rules (collapse (get-atoms $space)))
    ($narsRules (collapse (convertRuleToNars (superpose $rules))))
    ($_ (println! (narsRules $narsRules)))
    ($newRules (applyInference' $narsRules ()))
        
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
;;!(intersection-atom ((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) ( (((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1))))) 
;;(((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002))
;;!(match &self (($a --> $b) $c) $c)
;;!(let (($A --> $B) $stv) (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002)) $A)
;;!(reason (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002)) 
;;          (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1)))) (STV 0.5 0.002)))
;;!(applyInference &rulespace)
!(reasoningSelector (LEFT_SQUARE STILL_ALIVE) (CENTER_SQUARE STILL_ALIVE) &rulespace &cachespace)


;;!(convertRuleToPSI (1 (((((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((RIGHT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (0.5 0.002))))
