;;!(import! &self rule-helpers)

;; Math utilities for Metta

; (: isBetween (-> Number Number Number Bool))
(= (isBetween $val $low $high) (and (>= $val $low) (<= $val $high)))

; (: round (-> Number Number Number))
(= (round-sig $num $sig) (py-call ("round" $num $sig)))

(= (getRandomInt $a $b) (py-call ("random.randint" $a $b)))

; (: getRandom (-> Number))
(= (getRandom) (py-call ("random.random")))

; (: natural-log (-> Number Number))
(= (natural-log $x) (py-call ("math.log" $x)))

; (: sampleEngine (-> Number Number Number Number Number Number))
(= (sampleEngine $alpha $beta $a $b $gamma) (
    let* (
        ($u1 (getRandom))
        ($u2 (getRandom))
        ($v (* $beta (natural-log (/ $u1 (- 1 $u1)))))
        ($w (* $a (exp $v)))
        ($temp (natural-log (/ $alpha (+ $b $w))))
        ($left (+ (* $alpha $temp) (* $gamma $v)))
        ($right (+ (natural-log 4) (natural-log (* (* $u1 $u1) $u2))))
    ) (if (>= $left $right)
        (round-sig (/ $w (+ $b $w)) 4)
        (sampleEngine $alpha $beta $a $b $gamma)
    )
))

; (: betaSample (-> Number Number Number))
(= (betaSample $a $b) (
    let* (
        ($alpha (+ $a $b))
        ($beta (if (<= (min $a $b) 1) (max (/ 1 $a) (/ 1 $b)) (sqrt-math (/ (- $alpha 2) (- (* 2 (* $a $b)) $alpha))))) 
        ($gamma (/ (+ $a 1) $beta))
    ) (sampleEngine $alpha $beta $a $b $gamma)
))
;; Utility functions for Thompson Sampling based action planner
; (: confidenceToCount (-> Number Number))
(= (confidenceToCount $confidence) (
    / (* $confidence 800) (- 1 $confidence)
))

;; Convert count to confidence
; (: countToConfindence (-> Number Number))
(= (countToConfindence $count) (
    / $count (+ 800 $count)
))

;; Convert strength and confidence to alpha and beta parameters of Beta distribution
; (: stvToBeta (-> (Number Number) (Number Number)))
(= (stvToBeta ($strength $confidence)) (
    let* (
        ($count (confidenceToCount $confidence))
        ($alpha (* $strength $count))
        ($beta (- $count $alpha))
    ) ($alpha $beta)
))

;; Convert alpha and beta parameters of Beta distribution to strength and confidence
; (: betaToSTV (-> (Number Number) (Number Number)))
(= (betaToSTV ($alpha $beta)) (
    let* (
        ($count (+ $alpha $beta))
        ($strength (round-sig (/ $alpha $count) 2))
        ($confidence (+ 0.001 (round-sig (countToConfindence $count) 2))) ;; A small value should be added to avoid 0 when rounding
    ) ($strength $confidence)
))

;; Match goal in the rule space and return applicable rule IDs
; (: matchGoal (-> Expression hyperon::space::DynSpace Expression))
(= (matchGoal $goal $space) (
    collapse (match $space (: Rule $id $ttv $stv $comp $context $action (Goal $goal)) $id)
))

;; Get rule details by rule ID
; (: getRule (-> Number hyperon::space::DynSpace Expression))
(= (getRule $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp $context $action $goal) (: Rule $ruleId $ttv $stv $comp $context $action $goal)
))

;; Get specific attributes (Contexts) of a rule by rule ID
; (: getContext (-> Number hyperon::space::DynSpace Expression))
(= (getContext $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp (Context $context) $action $goal) $context
))

;; Get specific attributes (STV) of a rule by rule ID
(= (getSTV $ruleId $space) (
    match $space (: Rule $ruleId $ttv (STV $s $c) $comp $context $action $goal) ($s $c)
))

;; Get specific attributes (Action) of a rule by rule ID
(= (getAction $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp $context (Action $action) $goal) $action
))

;; Match context with rule contexts and return matching rule ID or Empty. All the contexts in the rule must match.
(= (matchContext $ruleId $context $space) (
    let* (
        ($ruleContext (getContext $ruleId $space))
        ($contextCount (size-atom $ruleContext))
        ($intersection (intersection-atom $ruleContext $context))
        ($matchCount (size-atom $intersection))
    ) 
    (if (== $contextCount $matchCount)
        $ruleId
        (empty)
    )
))

;; Match multiple contexts with rule contexts and return matching rule IDs
(= (matchContexts $ruleIds $context $space) (
    collapse (let $ruleId (superpose $ruleIds) (matchContext $ruleId $context $space))
))


;; Thompson Sampling to select a rule based on its STV values
(= (thompsonSample $ruleIds $space) (
    if (== $ruleIds ())
        (-1 0) ; (RuleID, Sampled Value)
    (let* (
        (($ruleId $rest) (decons-atom $ruleIds))
        ($_ (println! ("Considering rule: " $ruleId)))
        (($strength $confidence) (getSTV $ruleId $space))
        (($alpha $beta) (stvToBeta ($strength $confidence)))
        ($sample (betaSample $alpha $beta))
        ($_ (println! ("Rule " $ruleId " gave sample: " $sample)))
        (($chosenId $chosenSample) (thompsonSample $rest $space))
    ) (if (>= $sample $chosenSample) 
        ($ruleId $sample) 
        ($chosenId $chosenSample)
    ))
))

;; Perform the action associated with the rule in the given context and return result (1 for success, 0 for failure)
(= (performAction $ruleId $context $space) (
    let* (
        ($action (getAction $ruleId $space))
        ($_ (println! ("Performing action: " $action " in context: " $context)))
    ) (if (and (== $action (ATTACK SWORD)) (== $context ((Position CLOSE_RANGE))))
        1
        (if (and (== $action (ATTACK BOW)) (== $context ((Position MID_RANGE))))
            1
            (if (and (== $action (CAST FIREBALL)) (== $context ((Position LONG_RANGE))))
                1
                0
            )
        )
    )
))

;; Update Atoms in a space
(= (updateAtom $space $oatom $natom) 
    (let $_ (remove-atom $space $oatom)
        (add-atom $space $natom)
    ))

;; Update STV of a rule by rule ID
(= (updateSTV $ruleId ($s $c) $space) (
    let* (
        ($rule (getRule $ruleId $space))
        ($_ (println! ("Old rule: " $rule)))
        ((: Rule $ruleId $ttv (STV $os $oc) $comp $context $action $goal) $rule)
        ($newRule (: Rule $ruleId $ttv (STV $s $c) $comp $context $action $goal))
        ($x (updateAtom $space $rule $newRule))
        ($_ (println! ("New rule: " $newRule)))
    ) ()
))

;; Update rule after action execution based on result (1 for success, 0 for failure)
(= (updateRule $ruleId $result $space) (
    let* (
        (($strength $confidence) (getSTV $ruleId $space))
        (($alpha $beta) (stvToBeta ($strength $confidence)))
        ($newAlpha (if (== $result 1) (+ $alpha 1) $alpha))
        ($newBeta (if (== $result 1) $beta (+ $beta 1)))
        (($newStrength $newConfidence) (betaToSTV ($newAlpha $newBeta)))
        ($_ (updateSTV $ruleId ($newStrength $newConfidence) $space))
    ) ()
))
;;(= (getHandle $rule) (unify (dummy x) $rule $handle NONE))
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
(: Rule $ruleId $ttv $stv $comp (Context $context) $action $goal)
(= (getRuleIdWithStv $rule) (let (: Rule $id $temporal $stv $comp (IMPLICATION (AND $context $action) $goal)) $rule ($id $stv)))
(= (changeSTVToBeta $ruleIdWithSTV)
  (let* (
    ($_ (println! (ruleIdWithSTV $ruleIdWithSTV)))
    (($ruleId $stv) $ruleIdWithSTV)
    ((STV $strength $confidence) $stv)
    ($result (stvToBeta ($strength $confidence)))
  )
    ($ruleId $result)
  )
)
;;(: convertShortToBetaSample (-> Expression Expression))
(= (convertShortToBetaSample $shortRule)
    (let* (
      (($ruleId ($a $b)) $shortRule)
      ($betaResult (betaSample $a $b))
    )
      ($ruleId $betaResult)
    )

)

(= (addGameRules $space) (
    let $rules (superpose (
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
        )) (add-atom $space $rules)
))

!(addGameRules &ruleSpace)
(= (probBasedSample $ruleSpace $k)
    (let* (
        ($rules (collapse (get-atoms $ruleSpace)))
        ($_ (println! (rules $rules)))
        ($ids (collapse (getRuleIdWithStv (superpose $rules))))
        ($_ (println! (ids $ids)))
        ($idsWithBeta (collapse (changeSTVToBeta (superpose $ids))))
        ($_ (println! (idsWithBeta $idsWithBeta)))
        ($idsWithDistrib (collapse (convertShortToBetaSample (superpose $idsWithBeta))))
        ($sortedRules (sortRules $idsWithDistrib dec))
        ($selectedRules (if (>= $k (size-atom $rules)) $sortedRules (let ($left $right) (splitAt  $k  $sortedRules)  $left)))
        
        )
            $selectedRules 
    )
)

(= (splitAt $n $list)
   (case ($n $list)
     (
       ((0 $list) (() $list))
       (($_ ()) (() ()))
       (($n $list)
          (let*
             (
               (($x $xs) (decons $list))
               (($left $right) (splitAt (- $n 1) $xs))
             )
             ((cons-atom $x $left) $right)
          )
       )
     )
   )
)
(= (mergeSortRules () $right $cmp) $right)
(= (mergeSortRules $left () $cmp) $left)

(= (mergeSortRules $left $right $cmp)
     (let* (
            ((($lid $lh) $lt) (decons-atom $left))

            ((($rid $rh) $rt) (decons-atom $right))
            ($res1 (mergeSortRules $lt $right $cmp))
            ($res2 (mergeSortRules $left $rt $cmp))
            )
       (if ($cmp $lh $rh)
         (cons-atom ($lid $lh) $res1)
         (cons-atom ($rid $rh) $res2)
         )
       )
     )

(= (sortRules $list $key)
   (if (<= (size-atom $list) 1)
       $list
       (let* (
               ($mid (floor-math (/ (size-atom $list) 2)))
       (($left $right) (splitAt $mid $list))
               ($cmp (if (== dec $key) > <=))
             )
             (mergeSortRules (sortRules $left $key) (sortRules $right $key) $cmp)
       )
   )
)

(= (getRuleById $space $id) 
    (match $space  
        (: Rule $id $temporal $stv $comp (IMPLICATION (AND $context $action) $goal)) 
          (: Rule $id $temporal $stv $comp (IMPLICATION (AND $context $action) $goal))))
!(probBasedSample &ruleSpace 4)
!(getRuleIdWithStv (get-atoms &ruleSpace))
(= (collectRules $space $values $accum)
  (if (== $values ())
    $accum
    (let* (
      (($head $tail) (decons-atom $values))
      (($id $val) $head)
      ($rule (getRuleById $space $id))
      ($accum' (cons-atom $rule $accum))
    )
      (collectRules $space $tail $accum')
    )
  )

 )
;;!(collectRules &ruleSpace ((2 1.0) (1 0.9715) (7 0.9689) (5 0.8104)) ())
