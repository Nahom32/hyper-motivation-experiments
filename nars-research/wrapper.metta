
;;!(import! &self NARS)

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
((: r1 ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK 
              (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue)) (Goal Send-Greeting 1.0 1.0)))) 4)
(= (convertScheme ((: $handle ($tv (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight))
    (let (TTV $time (STV $f $c)) $tv (((AND_LINK ($context $action)) --> $goal) ($f $c))))
(= (findRulesWithHandle $space $handle)
    (collapse (match $space (( $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) (Goal $goal $x $y)))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) (Goal $goal $x $y)))) $weight)
        
    ))
)

(= (addRules $space) 
    (let $atoms (superpose (

    ;; r30 Return to base on alert
    ((: r30 ((TTV 1 (STV 0.8 0.75)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal battery_alert 0.95 0.8) return)) 
            (Goal base_reached 1.0 1.0)))) 5)

    ;; r31 Dock when base reached
    ((: r31 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal base_reached 0.9 0.75) dock)) 
            (Goal docked 1.0 1.0)))) 2)

    ;; r32 Charge when docked
    ((: r32 ((TTV 1 (STV 0.85 0.8)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal docked 0.95 0.85) charge)) 
            (Goal full_energy 1.0 1.0)))) 3)

    ;; r33 Shutdown after charge
    ((: r33 ((TTV 1 (STV 0.65 0.6)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal full_energy 0.9 0.75) shutdown)) 
            (Goal system_off 1.0 1.0)))) 1)
    ((: r33' ((TTV 1 (STV 0.65 0.6)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal less_energy 0.9 0.75) shutdown)) 
            (Goal system_off 1.0 1.0)))) 1)


    ;; r34 Wake when system off
    ((: r34 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal system_off 0.85 0.7) wake)) 
            (Goal system_on 1.0 1.0)))) 3)

    ;; r35 Initialize sensors
    ((: r35 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal system_on 0.9 0.75) init_sensors)) 
            (Goal sensors_ready 1.0 1.0)))) 2)

    ;; r36 Train model after sensors ready
    ((: r36 ((TTV 1 (STV 0.85 0.8)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal sensors_ready 0.95 0.85) train)) 
            (Goal model_trained 1.0 1.0)))) 4)

    ;; r37 Predict after training
    ((: r37 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal model_trained 0.9 0.75) predict)) 
            (Goal prediction_ready 1.0 1.0)))) 3)

    ;; r38 Validate after prediction
    ((: r38 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal prediction_ready 0.85 0.7) validate)) 
            (Goal validation_done 1.0 1.0)))) 2)

    ;; r39 Save model after validation
    ((: r39 ((TTV 1 (STV 0.8 0.75)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal validation_done 0.95 0.8) save)) 
            (Goal model_saved 1.0 1.0)))) 3)

    ;; r40 Deploy after saving model
    ((: r40 ((TTV 1 (STV 0.9 0.85)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal model_saved 0.9 0.75) deploy)) 
            (Goal model_deployed 1.0 1.0)))) 5)
)) (add-atom $space $atoms)))
(= (convertRulesToNars $space)
  (let $values (collapse (get-atoms $space)) (collapse (convertScheme (superpose $values))))
)
!(addRules &test)
!(get-atoms &test)
;;(: isMember (-> $aa Expression Bool))
(= (isMember $item $list) 
        (if (== $list ()) 
            False 
            (let ($head $tail) (decons-atom $list) 
                (if (== $head $item) 
                    True 
                    (isMember $item $tail)))))


(= (all $expression)
    (let $exp (collapse (if (== (superpose $expression) True) True (empty))) (if (< (size-atom $exp) (size-atom $expression)) False True))
)
(= (any $expression)
    (let $exp (collapse (if (== (superpose $expression) True) True (empty))) (if (== $exp ()) False True)))


;;(: isReduced (-> Expression Bool))
;;(= (isReduced $value) (all (collapse (not (isMember reason (superpose $value))))))
;;(= (isReduced $value) (not (isMember reason $value)))
(= (isReduced $value) (if (== $value ())False True))
(= (applyInferenceForRule $rule $rules $accum)
  (if (== $rules ())
     $accum
    (let* (
        (($head $tail) (decons-atom $rules))
        ($s_ (println! (forApplication $rule space $head)))
        ($result (reason $rule $head))
        ($_ (println! (results $result)))
        ($reduced (isReduced $result))
        ($_ (println! (reduced $reduced)))
        ($accum' (if (not $reduced) $accum (union-atom $accum ($result))))
    ) 
      (applyInferenceForRule $rule $tail  $accum')
  )
))

(= (applyInference' $rules $counter $accum)
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
     (applyInference' $tail $counter' $accum')
    )
  )
)

(= (applyInference $space)
  (let* (
    ($narsRules (convertRulesToNars $space))
    ($_ (println! (narsRules $narsRules)))
    ($newRules (applyInference' $narsRules $counter ()))
        
  )
    $newRules
  )
)
;;!(applyInference &test)


!(reason (convertScheme ((: r33' ((TTV 1 (STV 0.65 0.6)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal less_energy 0.9 0.75) shutdown)) 
            (Goal system_in 0.9 1.0)))) 1)
    )
    (convertScheme 
        ((: r33 ((TTV 1 (STV 0.65 0.6)) 
                (IMPLICATION_LINK 
                (AND_LINK ((Goal full_energy 0.9 0.75) shutdown))  
                (Goal system_off 1.0 1.0)))) 1)))
    

(= (randomizer' $size $accum $sentinel $noOfSamples)
  (if (== $size 0) $accum
      (let* (
        ($randVal (random-int &rng 0 $noOfSamples))
        ($isMember (isMember $randVal $accum))
      )
        (if $isMember (randomizer' (- $size 1) $accum $sentinel $noOfSamples) (randomizer' (- $size 1) (cons-atom $randVal $accum) $sentinel $noOfSamples))
    ))
)


;;!(randomizer' 10 () 20 4)
(= (randomizer $list $size) (randomizer' $size () (size-atom $list) $size))
;;(:selectRandom (-> Expression Number Expression))
(= (selectRandom $list $size) 
    (let* (
      ($randomList (randomizer $list $size))
      ($selectedValues (massSelect $list $randomList ()))

    )
      $selectedValues
    ))
;;(: massSelect (-> Expression Expression Expression Expression))
(= (massSelect $list $indiceList $acc)
    (if (== $indiceList ()) 
        $acc 
        (let* (
          (($head $tail) (decons-atom $indiceList))
          ($val (index-atom $list $head))
          ($acc' (cons-atom $val $acc))
        )  
          (massSelect $list $tail $acc')
        )
    )
)

;;!(selectRandom (a b c d e f g h i j k l m n o p q r s t u v w x y z) 10)
;;!(size-atom (collapse (match &test ((r33 $schema) $weight) $schema)))

(= (greedySelection' $list $best $evalFunc)
  (if (== $list ())
    $best
    (let* (
      (($head $tail) (decons-atom $list))
      ($bestEval ($evalFunc $best))
      ($headEval ($evalFunc $head))
    )
      (if ( >= $bestEval $headEval) (greedySelection' $tail $best $evalFunc) (greedySelection' $tail $head $evalFunc))
    )
  )
)


(= (convertSchemeToNars (: Rule $id $ttv $stv1 $complexity (IMPLICATION (AND $context $action) $goal))) ((AND ($context $action)) --> $goal $stv1))


!(convertSchemeToNars (: Rule 1
    (TTV 0)
    (STV 0.5 0.002)  
    (Complexity 1)
    (IMPLICATION
        (AND 
            (Context (STV 0.2 0.1) (AND (
                (LEFT_SQUARE (STV 0.2 0.1))
                (STILL_ALIVE (STV 0.2 0.1)))))
            (Action (SEQ_AND (MOVE_RIGHT)) ) )
        (Goal (STV 0.2 0.1) (AND (
                (CENTER_SQUARE (STV 0.2 0.1))
                (STILL_ALIVE (STV 0.2 0.1)))
    )) 
)))
(= (getRulesByContext $space $context) (collapse (match &self (: Rule $index $ttv $complexity 
              (IMPLICATION (AND (Context $contextStv $context) $action $goal))))))
;;(: (greedySelection (-> Expression (-> Expression Number) Expression)))
(= (greedySelection $list $evalFunc)
  (if (== $list ()) $list (let ($head $tail) (decons-atom $list) (greedySelection $tail $head $evalFunc)))
)

(= (greedyPlanner $ruleSpace $context $evalFunc)
    (let $rules (getRulesByContext $ruleSpace $context) (greedySelection $rules $evalFunc))
)
!(allResullts (all (True True True False)))
!(anyResullts (any (True True True False)))
!(applyInference &test)
(= (addRules $rules $space)
  (if (== $rules ()) 
    ()
    (let* (
      ($availableRules (collapse (get-atoms $space)))
      (($head $tail) (decons-atom $rules))
      ($_ (if (not (isMember $head $availableRules)) (add-atom $space $head) ()))
      
    )
      (addRules $tail $space)
    )
  )
)
(= (reasoningSelector $space)
  (let* (
    ($inferedRules (applyInference $space))
    ($_ (addRules $inferedRules $space))

  )
    (collapse (get-atoms $space))
  )
)

!(reasoningSelector &test)

