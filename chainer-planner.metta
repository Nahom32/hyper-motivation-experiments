;; Standalone backward chaining experiments.

;;;;;;;;;
;; Nat ;;
;;;;;;;;;

;; Define Nat
(: Nat Type)
(: Z Nat) ;; initial 
(: S (-> Nat Nat))

;; Define cast functions between Nat and Number
(: fromNumber (-> Number Nat))
(= (fromNumber $n) (if (<= $n 0) Z (S (fromNumber (- $n 1)))))
(: fromNat (-> Nat Number))
(= (fromNat Z) 0)
(= (fromNat (S $k)) (+ 1 (fromNat $k)))

;;;;;;;;;;;;;;;;;
;; Bare Entail ;;
;;;;;;;;;;;;;;;;;

;; Variant of entail where ⊢ is not wrapped around the knowledge base.

! "=== Bare Entail ==="

;; Backward chainer
(: bc_bare (-> Atom (-> Atom) (-> Atom) Nat Atom))
;; Base case
(= (bc_bare $conclusion $kb $rb $depth)
   (let $conclusion ($kb) $conclusion))
;; Recursive step
(= (bc_bare $conclusion $kb $rb (S $k))
   (let* (((⊢ $premise1 $premise2 $conclusion) ($rb))
          ($premise1 (bc_bare $premise1 $kb $rb $k))
          ($premise2 (bc_bare $premise2 $kb $rb $k)))
     $conclusion))

;; Knowledge base
(: kb_bare (-> Atom))
(= (kb_bare) (superpose ((→ A B)
                         (→ B C)
                         A)))

;; Rule base
(: rb_bare (-> Atom))
(= (rb_bare) (⊢
              ;; Premises
              (→ $p $q)
              $p
              ;; Conclusion
              $q))

;; Test backward chainer
!(assertEqual
  (bc_bare A kb_bare rb_bare Z)
  A)
!(assertEqual
  (bc_bare B kb_bare rb_bare (fromNumber 1))
  B)
!(assertEqual
  (bc_bare C kb_bare rb_bare (fromNumber 2))
  C)
!(assertEqualToResult
  (bc_bare D kb_bare rb_bare (fromNumber 4))
  ())

;;;;;;;;;;;;;;
;; Equality ;;
;;;;;;;;;;;;;;

! "=== Equality ==="

;; Knowledge base
(: kb_eq (-> Atom))
(= (kb_eq) (superpose ((→ A B)
                       (→ B C)
                       A)))

;; Backward chainer.  The rule based is directly embedded in the
;; backward chainer function.
(: bc_eq (-> Atom (-> Atom) Nat Atom))
;; Base case
(= (bc_eq $conclusion $kb $depth)
   (let $conclusion ($kb) $conclusion))
;; Recursive step (modus ponens)
(= (bc_eq $q $kb (S $k))
   (let* (((→ $p $q) (bc_eq (→ $p $q) $kb $k)) ; premise1
          ($p (bc_eq $p $kb $k)))              ; premise2
     $q))                                      ; conclusion
;; Recursive step (deduction)
(= (bc_eq (→ $p $r) $kb (S $k))
   (let* (((→ $p $q) (bc_eq (→ $p $q) $kb $k))  ; premise1
          ((→ $q $r) (bc_eq (→ $q $r) $kb $k))) ; premise2
     (→ $p $r)))                                ; conclusion

;; Test backward chainer
!(assertEqual
  (bc_eq A kb_eq Z)
  A)
!(assertEqual
  (bc_eq B kb_eq (fromNumber 1))
  B)
!(assertEqualToResult
  (bc_eq C kb_eq (fromNumber 2))
  (C   ; 2 modus ponens
   C)) ; deduction + modus ponens
!(assertEqual
  (bc_eq (→ A B) kb_eq (fromNumber 0))
  (→ A B))
!(assertEqual
  (bc_eq (→ B C) kb_eq (fromNumber 0))
  (→ B C))
!(assertEqual
  (bc_eq (→ A C) kb_eq (fromNumber 2))
  (→ A C))

;;;;;;;;;;;;;;;;;;;;;;;
;; Bare Entail Match ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; Like bare entail but let is replaced by match

! "=== Bare Entail Match ==="

;; Knowledge base
!(bind! &kb_bem (new-space))
!(add-atom &kb_bem (→ A B))
!(add-atom &kb_bem (→ B C))
!(add-atom &kb_bem A)

;; Rule base
!(bind! &rb_bem (new-space))
!(add-atom &rb_bem (⊢
                    ;; Premises
                    (→ $p $q)
                    $p
                    ;; Conclusion
                    $q))
!(add-atom &rb_bem (⊢
                    ;; Premises
                    (→ $p $q)
                    (→ $q $r)
                    ;; Conclusion
                    (→ $p $r)))

;; Backward chainer
(: bc_bem (-> Atom Nat Atom))
;; Base case
(= (bc_bem $conclusion $depth)
   (match &kb_bem $conclusion $conclusion))
;; Recursive step
(= (bc_bem $conclusion (S $k))
   (match &rb_bem (⊢ $premise1 $premise2 $conclusion)
          (let* (($premise1 (bc_bem $premise1 $k))
                 ($premise2 (bc_bem $premise2 $k)))
            $conclusion)))

;; Test backward chainer
!(assertEqual
  (bc_bem A Z)
  A)
!(assertEqual
  (bc_bem B (fromNumber 1))
  B)
!(assertEqualToResult
  (bc_bem C (fromNumber 2))
  (C   ; 2 modus ponens
   C)) ; deduction + modus ponens
!(assertEqual
  (bc_bem (→ A B) (fromNumber 0))
  (→ A B))
!(assertEqual
  (bc_bem (→ B C) (fromNumber 0))
  (→ B C))
!(assertEqual
  (bc_bem (→ A C) (fromNumber 2))
  (→ A C))

;;;;;;;;;;;;;;;;;;;;
;; Equality Match ;;
;;;;;;;;;;;;;;;;;;;;

;; Like equality but let is replaced by match

! "=== Equality Match ==="

;; Knowledge base
!(bind! &kb_em (new-space))
!(add-atom &kb_em (→ A B))
!(add-atom &kb_em (→ B C))
!(add-atom &kb_em A)

;; Backward chainer.  The rule based is directly embedded in the
;; backward chainer function.
(: bc_em (-> Atom Nat Atom))
;; Base case
(= (bc_em $conclusion Z)
   (match &kb_em $conclusion $conclusion))
;; Recursive step (modus ponens)
(= (bc_em $q (S $k))
   (let* (((→ $p $q) (bc_em (→ $p $q) $k)) ; premise1
          ($p (bc_em $p $k)))              ; premise2
     $q))                                  ; conclusion
;; Recursive step (deduction)
(= (bc_em (→ $p $r) (S $k))
   (let* (((→ $p $q) (bc_em (→ $p $q) $k))  ; premise1
          ((→ $q $r) (bc_em (→ $q $r) $k))) ; premise2
     (→ $p $r)))                            ; conclusion

;; Test backward chainer
;; !(assertEqual
;;   (bc_em A Z)
;;   A)
;; !(assertEqual
;;   (bc_em B (fromNumber 1))
;;   B)
;; !(assertEqualToResult
;;   (bc_em C (fromNumber 2))
;;   (C   ; 2 modus ponens
;;    C)) ; deduction + modus ponens
;; !(assertEqual
;;   (bc_em (→ A B) (fromNumber 0))
;;   (→ A B))
;; !(assertEqual
;;   (bc_em (→ B C) (fromNumber 0))
;;   (→ B C))
;; !(assertEqual
;;   (bc_em (→ A C) (fromNumber 2))
;;   (→ A C))

;;;;;;;;;;;;;;;;;;;;;;;;
;; DTL Equality Match ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Like DTL (Synthesizer) but the rules are hard wired in the backward
;; chainer and match is used instead of let (as far as matching
;; premises is concerned).

! "=== DTL Equality Match ==="

;; Knowledge base
!(bind! &kb_dem (new-space))
!(add-atom &kb_dem (: ab (→ A B)))
!(add-atom &kb_dem (: bc (→ B C)))
!(add-atom &kb_dem (: a A))

;; Backward chainer.  The rule based is directly embedded in the
;; backward chainer function.
(: bc_dem (-> Atom Nat Atom))
;; Base case
(= (bc_dem (: $prf $conclusion) $depth)
   (match &kb_dem (: $prf $conclusion) (: $prf $conclusion)))
;; Recursive step (modus ponens)
(= (bc_dem (: $prf_q $q) (S $k))
   (let* (((: $prf_pq (→ $p $q)) (bc_dem (: $prf_pq (→ $p $q)) $k)) ; premise1
          ((: $prf_p $p) (bc_dem (: $prf_p $p) $k))                 ; premise2
          ((: (ModusPonens $prf_pq $prf_p) $q) (: $prf_q $q)))      ; conclusion
     (: $prf_q $q)))
;; Recursive step (deduction)
(= (bc_dem (: $prf_pr (→ $p $r)) (S $k))
   (let* (((: $prf_pq (→ $p $q)) (bc_dem (: $prf_pq (→ $p $q)) $k))          ; premise1
          ((: $prf_qr (→ $q $r)) (bc_dem (: $prf_qr (→ $q $r)) $k))          ; premise2
          ((: (Deduction $prf_pq $prf_qr) (→ $p $r)) (: $prf_pr (→ $p $r)))) ; conclusion
     (: $prf_pr (→ $p $r))))

;; Test backward chainer
;; !(assertEqual
;;   (bc_dem (: $prf A) Z)
;;   (: a A))
;; !(assertEqual
;;   (bc_dem (: $prf (→ A B)) Z)
;;   (: ab (→ A B)))
;; !(assertEqual
;;   (bc_dem (: $prf B) (fromNumber 1))
;;   (: (ModusPonens ab a) B))
;; !(assertEqualToResult
;;   (bc_dem (: $prf C) (fromNumber 2))
;;   ((: (ModusPonens bc (ModusPonens ab a)) C)
;;    (: (ModusPonens (Deduction ab bc) a) C)))
;; !(assertEqual
;;   (bc_dem (: $prf (→ A B)) (fromNumber 0))
;;   (: ab (→ A B)))
;; !(assertEqual
;;   (bc_dem (: $prf (→ B C)) (fromNumber 0))
;;   (: bc (→ B C)))
;; !(assertEqual
;;   (bc_dem (: $prf (→ A C)) (fromNumber 2))
;;   (: (Deduction ab bc) (→ A C)))

;; !(bc_dem (: $prf C) (fromNumber 2))

;; !(kb_bare)
(: bcSearch (-> Atom 
                Atom 
                (-> Atom 
                    Atom 
                    Expression) 
                Expression))
(= (bcSearch $space 
              $conclusion 
              $structFunc)
    (let* (
      ($rules ($structFunc $space $conclusion))
      (() (println! (rules $rules)))

    )
      $rules
    )
    
   
)
  


(: bcChainer (-> Atom 
                   Atom 
                   (-> Atom 
                       Atom 
                       Expression) 
                   Nat 
                   Expression))
(= (bcChainer $space 
               $conclusion 
               $structFunc 
               Z)
   (bcSearch $space $conclusion $structFunc))
(= (bcChainer $space 
               $conclusion 
               $structFunc 
               (S $Z))
   (let $result (bcSearch $space $conclusion $structFunc)
        (if  (== $result ())
                 $result
                ((bcChainer 
                        $space 
                        $result 
                        $structFunc 
                        $Z) $result)
               
        )))
(= (filterHasInit $initConditions $actions)
    (if (== $actions ())
        (empty)
      (if (== (car-atom $actions) $initConditions)
          $actions
          (empty)
      )
    )
)
(: actionPlanner 
        (-> Atom 
            Action
            Action 
            (-> Atom 
                Atom 
                Expression) 
                Expression))
(= (actionPlanner $space 
                  $initCondition 
                  $goalCondition 
                  $structFunc)
    (let $actions (collapse (bcChainer $space $goalCondition $structFunc (fromNumber 100)))
          $actions
        ;; (collapse (filterHasInit $initConditions (superpose $actions))) 
    )

)
(= (findRulesWithAction $space $action)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        
    ))
)

;; (: findActionWithGoal (-> Atom 
;;                         Goal
;;                         Expression))
(= (findRulesWithGoal $space $goal)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) (Goal $goal $x $y)))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) (Goal $goal $x $y)))) $weight)
        
    ))
)

(= (findActionWithGoal $space $goal)
    (let $rules (findRulesWithGoal $space $goal)
        (collapse (extractContextFromRule (superpose $rules)))
         
    )
)
(= (extractGoalFromRule $rule)
    (let ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight) $rule $goal)

)
(= (extractContextFromRule $rule)
    (let ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight) $rule $context)
)

(= (findGoalsWithAction $space $action)
    (let $rules (findRulesWithAction $space $action)
        (collapse (extractGoalFromRule (superpose $rules)))
         
    )
)

(= (extractGoalName $goal)
    (let (Goal $name $x $y) $goal $name)

)

(= (findContextWithAction $space $action)
    (let* (
      ($rules (findRulesWithAction $space $action))
      ($priors (collapse (extractContextFromRule (superpose $rules))))
      ($contexts (collapse (extractGoalName (superpose $priors))))

    ) 

       $contexts
         
    )
)



(= (addRulesToSpace $space)
    (add-reduct $space (superpose (
            
((: r1 ((TTV 1 (STV 0.8 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.9 0.6) explore)) 
          (Goal found_target 1.0 1.0)))) 2)

;; r2: Approach after finding target
((: r2 ((TTV 1 (STV 0.75 0.65)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal found_target 1.0 1.0) approach)) 
          (Goal near_target 1.0 1.0)))) 3)

;; r3: Interact when near
((: r3 ((TTV 1 (STV 0.7 0.6)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal near_target 1.0 1.0) interact)) 
          (Goal task_done 1.0 1.0)))) 2)

;; r4: Report task done
((: r4 ((TTV 1 (STV 0.65 0.6)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal task_done 1.0 1.0) report)) 
          (Goal mission_complete 1.0 1.0)))) 10)

;; r5: Do nothing and become low energy
((: r5 ((TTV 1 (STV 0.5 0.5)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.8 0.5) idle)) 
          (Goal low_energy 1.0 1.0)))) 1)

;; r6: Analyze after mission complete
((: r6 ((TTV 1 (STV 0.75 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal mission_complete 0.9 0.7) analyze)) 
          (Goal analyze_data 1.0 1.0)))) 4)

;; r7: Upload results after analysis
((: r7 ((TTV 1 (STV 0.7 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal analyze_data 0.85 0.7) upload)) 
          (Goal upload_results 1.0 1.0)))) 2)

;; r8: Reboot after upload
((: r8 ((TTV 1 (STV 0.9 0.8)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal upload_results 0.95 0.75) reboot)) 
          (Goal reset_system 1.0 1.0)))) 1)

            )
        )
    )

)
!(bind! &kb (new-space))
!(addRulesToSpace &kb)
!(get-atoms &kb)
!(actionPlanner &kb init task_done findActionWithGoal)
;; !(fromNumber 10)


;; What should be the halting condition for the backward-chainer ?
;; 
;; so how does the following work out?







