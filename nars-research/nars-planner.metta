!(import! &self sampler)
!(import! &self rule-ops)

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

(: Rule 1
        (TTV 0)
        (STV 0.5 0.002)  
        (Complexity 1)
        (IMPLICATION
            (AND 
                (Context (STV 0.2 0.1) (AND (
                    (RIGHT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_GO (MOVE_RIGHT))))
            (Goal (STV 0.2 0.1) (AND (
                    (CENTER_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))
        )) 
    ))

;;(: convertRulesToPSI (-> Expression Expression))
(= (convertRuleToPSI $rule)
    (if (== $rule ()) ()
    (let* (
      (($id (($precedent --> $antecedent) ($freq $conf))) $rule)
      ($truthValue (STV $freq $conf)) 
      (($context $action) $precedent)
      ($goal $antecedent)

    )
      (: Rule $id 
        (TTV 0)
        $truthValue
        (Complexity 1)
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
                    (RIGHT_SQUARE (STV 0.2 0.1))
                    (STILL_ALIVE (STV 0.2 0.1)))))
                (Action (SEQ_GO (MOVE_RIGHT))))
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
)) (add-atom $space $rules)))

;; What if I use the following format ($id $rule-narsese)

!(addRules &rulespace)
;;!(get-atoms &rulespace)
;;!(generateId &rulespace)


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

;;!(convertRuleToNars  (: Rule 1
;;        (TTV 0)
;;        (STV 0.5 0.002)  
;;        (Complexity 1)
;;        (IMPLICATION
;;            (AND 
;;                (Context (STV 0.2 0.1) (AND (
;;                    (LEFT_SQUARE (STV 0.2 0.1))
;;                    (STILL_ALIVE (STV 0.2 0.1)))))
;;                (Action (SEQ_AND (MOVE_RIGHT))))
;;            (Goal (STV 0.2 0.1) (AND (
;;                    (CENTER_SQUARE (STV 0.2 0.1))
;;                    (STILL_ALIVE (STV 0.2 0.1)))
;;        )) 
;;    )))


;;!(unify 
;;  (: Rule $id $ttv $stv $complexity (IMPLICATION $contextAction $goal)) (: Rule 1
;;        (TTV 0)
;;        (STV 0.5 0.002)  
;;        (Complexity 1)
;;        (IMPLICATION
;;            (AND 
;;                (Context (STV 0.2 0.1) (AND (
;;                    (LEFT_SQUARE (STV 0.2 0.1))
;;                    (STILL_ALIVE (STV 0.2 0.1)))))
;;                (Action (SEQ_AND (MOVE_RIGHT))))
;;            (Goal (STV 0.2 0.1) (AND (
;;                    (CENTER_SQUARE (STV 0.2 0.1))
;;                    (STILL_ALIVE (STV 0.2 0.1)))
;;        )) 
;;    )) 
;;        true
;;        false
;;        
;;)


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


(= (reasoningSelector $space $cacheSpace)
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
    (collapse (get-atoms $space))
  )
)
;;!(intersection-atom ((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) ( (((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1))))) 
;;(((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002))
;;!(match &self (($a --> $b) $c) $c)
;;!(let (($A --> $B) $stv) (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002)) $A)
;;!(reason (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1)))) (STV 0.5 0.002)) 
;;          (((((LEFT_SQUARE (STV 0.2 0.1)) (STILL_ALIVE (STV 0.2 0.1))) (MOVE_RIGHT)) --> ((CENTER_SQUARE (STV 0.2 0.1)) (DEAD (STV 0.2 0.1)))) (STV 0.5 0.002)))
;;!(applyInference &rulespace)
!(reasoningSelector &rulespace &cachespace)
