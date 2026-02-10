;;(A --> B) & (B --> C) |- (A --> C) deduction
;;(B --> A) & (B --> C) |- (A --> C) induction
;;(A --> B) & (C --> B) |- (A --> C) abduction
;;(A --> B) & (B --> C) |- (C --> A) exemplification


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
; Exemplification Truth is hard to justify it with Context & Action schema
(= (reason $R1 $R2) (empty))



(= (convertRuleToPSI $rule)
    (let* (
        ($id 25) ;; temporary ID generation
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


