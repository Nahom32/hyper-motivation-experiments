!(import! &self demand-functions)
!(import! &self modulator-updaters)
!(import! &self feeling-updaters)
!(import! &self psi-utils)
!(import! &self action-planner-v1)
!(import! &self modulator)
!(bind! &kb (new-space))
;!(bind! &modulator-space (new-space))
;;!(bind! &demand-space (new-space))
!(bind! &rule-space (new-space))
!(bind! &cache-space (new-space))

;; This function removes all occurences of an existing pattern
;; how would we evaluate it? The action is planned, then the demand updater should update based on the plan

;; A function to be removed later on


;;!(bind! &modulator-space (new-space)) ;; a relation-space for adding links between categories and rules




!(insert-modulators &modulator-space)

;(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))


(: remove-atoms' (-> hyperon::space::DynSpace Expression Expression))
(= (remove-atoms' $space $expression)
    (if (== $expression ())
        ()
        (let* (
            (($head $tail) (decons-atom $expression))
            ($_ (remove-atom $space $head))
        )
            (remove-atoms' $space $tail)
        )
    )
)
;; This function removes values from a given atomspace
(:remove-atoms (-> hyperon::space::DynSpace))
(= (remove-atoms $space)
    (let $atoms (collapse (get-atoms $space))
        (remove-atoms' $space $atoms)
    )
)
;; Remove The remove occurrences function removes values based on a given 
;;pattern for instance a perception updater value can be stored as 
;;(perception value time)
(: remove-occurrences (-> hyperon::space::DynSpace Expression Expression)) 
(= (remove-occurrences $space $pattern)
   	(let $atoms (collapse (match $space $pattern $pattern))
	  	(remove-atoms $space $atoms)))





(= (ruleSpace) (&ruleSpace))
(= (modulatorSpace) (&modulator-space))
(= (demandSpace) (&demandspace))
(= (add-atoms $space $values)
	(add-reduct $space (superpose $values)))


;;The below function is used to synchronize two atomspaces for having the same
;;Replicated value. The updater space belongs to the mind-agent while the atomspace to be synchronized is the 
;; knowledge base atomspace.
(: update-atoms (-> Expression hyperon::space::DynSpace hyperon::space::DynSpace Expression ))
(= (update-atoms $pattern $updater $updated)
   	(let* (
	       ($updater-atoms (collapse (get-atoms $updater)))
	       ($_ (remove-occurrences $updated $pattern))
		    ($_ (collapse (add-atoms $space $updated)))
	       )
	  	()	
	  )
)



;;Tag based specification for atomspace updation
(: update-all (-> Symbol hyperon::space::DynSpace hyperon::space::DynSpace Expression))
(= (update-all $tag $updater $updater)
   (case $tag(
              (demand (update-atoms (demand $x $y) $updater $updated))
              (modulator (update-atoms (modulator $x $y) $updater $updated))
              )))



;; a querying mechanism of the knowledge base.
(= (query $space (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))))
   	(collapse (match $space (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal)))
	       (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))))

	))
(= (query $space (modulator $x $y)) (collapse (match $space (modulator $x $y) (modulator $x $y))))
(= (query $space (perception $x $y)) (collapse (match $space (perception $x $y) (perception $x $y))))
(= (query $space (demand $x $y)) (collapse (match $space (demand $x $y) (demand $x $y))))

(: queryAll (-> hyperon::space::DynSpace Symbol Expression))
(= (queryAll $space $type)
   (case $type(
	       (modulator (query $space (modulator $x $y)))
	       (perception (query $space (perception $x $y)))
	       (demand (query $space (demand $x $y)))
	       (rule (query $space (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal)))))
	       ($_ (Error "This form doesn't exist in the atomspace"))
	       )))



(: demandSelector' (-> Expression Number Demand))
(= (demandSelector' $demands $maxDemand)
   	(if (== $demands ()) 
	  	$maxDemand
		(let* (
		       	((demand $maxName $maxVal) $maxDemand)
		       	(((demand $currName $currVal) $tail) (decons-atom $demands))
		       )
		  	(if (>= $currVal $maxVal)
			  	(demandSelector' $tail (demand $currName $currVal))
				(demandSelector' $tail $maxDemand)
			)
		)
	)
)

;; (: demandSelector (-> Expression Demand))
(= (demandSelector $demands)
   	(if (== $demands ())
	  	(Error "No Demands Available")
		(demandSelector' $demands (car-atom $demands))))
;
;; A one to one relationship between a demand and a goal.
;; This goal selector maps from the demand and applies the goal to it
;; This is an unfinished function
(= (goalSelector $demand)
   (case $demand(
		 ((demand affiliation $y) (Goal mission_complete 1.0 1.0))
		((demand competence $x) (Goal mission_complete 1.0 1.0))
        ((demand energy $x) (Goal mission_complete 1.0 1.0))
	)
)
)

;; A for the matched llm value
;(: matchGoal (-> hyperon::space::DynSpace Expression Expression)) 
;(= (matchGoal $ruleSpace $actions)
 ;  	(goal1 context1)
;)
;;(: applyActions (-> Expression Goal Expression Expression))
(= (applyActions $actions $goal $demand) 
   (if (== $actions ())
     		()
		(let $isGoalMet? (isGoalMet? $actions $goal)
		  	(if $isGoalMet?
                (let* (
                       ($_ (println! (goalMet $isGoalMet?)))
                       ((demand $demandName $demandValue) $demand)
                )
			  	    (setDemandValue &demandspace $demandName 1.0)
                )
				()
			)
		)))
; A non-deterministic implementation of demand selection refer 
;; OpenPsi: A Novel Computational Affective Model and its Application in Video Games by Goertzel,Ben et. al (2013)
(: selectDemand (-> Expression Expression))
(= (selectDemand $demands)
   (let* (
	  ($selectionVal (fetch-modulator-val (modulatorSpace) selection-threshold))
	  ($randomVal (random-float $rng 0 1))
	)
     	(if (>= $selectionVal $randomVal)
	  	(demandSelector $demands)
		(let* (
			($length (size-atom $demands))
			($randIndex (random-int &rng 0 (- $length 1)))
			($demand (index-atom $demands $randIndex))
		)
		  $demand))))
;;What happens when actions are applied?
;;How are we going to solve the problem?
;;(: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)))
;; we  can write a function that selects rules based on actions, then we can take the function that has the biggest heuristic
(: selectRuleByAction (-> hyperon::space::DynSpace Symbol Expression)) 
(= (selectRuleByAction $ruleSpace $action)
   	(collapse (match $ruleSpace ((:$handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $val) ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $val))))

;; A temporary selector of rules which are selected based on having the same actions. 
(: selectMaxRule (-> Expression Expression Expression))
(= (selectMaxRule $rules $maxRule)
   	(if (== $rules ())
	  $maxRule
	(let* (
	       ((($rule $weight) $tail) (decons-atom $rules))
		    (($maxRule' $maxWeight) $maxRule)
	       )
	  (if (>= $maxWeight $weight)
		  	;;()
			(selectMaxRule $tail $maxRule)
			(selectMaxRule $tail $rule)

		)
	  	
	)))


;(: extractGoalFromRule (-> Expression Goal))
;(= (extractGoalFromRule $rule)
;	(unify $rule (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $goal ()))

;; This function is taken from the action planner in version 1. It will be removed
;;(= (findRulesWithAction $space $action)
;;   (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)      
;;((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        
;;)))
;; This function extracts the STV from RULE.
;; (: extractSTVFromRule (-> Expression Expression))
;; (= (extractSTVFromRule $rule)
;;   	(unify $rule (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)))
;;	       (STV $bel $conf)
;;	       ()
;;	)
;;)


(:isGoalMet' (-> Expression Goal Bool))
(= (isGoalMet' $rules $goal)
   	(if (== $rules ())
		False
		(let* (
			(($rule $tail) (decons-atom $rules))
            ($_ (println! (isGoalMetInnerRule $rule tail $tail)))
			($ruleGoal (extractGoalFromRule $rule))
            ($_ (println! (this is the goal $ruleGoal)))
		)
		  (if (== $ruleGoal $goal)
		    	True
		    	(isGoalMet' $tail $goal)
		  )
		)
	)
)


;; How would this function work? how can I check whether the goal is met?
;; This function is used for a follow-up after the action-selection mind agent
;; is applied.
(: isGoalMet? (-> Expression Goal Bool))
(= (isGoalMet? $actions $goal)
	(let* (
	       ($length (size-atom $actions))
	       ($lastAction (index-atom $actions (- $length 1)))
	       ($rules' (findRulesWithAction &ruleSpace $lastAction))
           ($_ (println! (rulesinGoal $rules')))
	)
		 (isGoalMet' $rules' $goal)
	)	
)


;; This function updates the modulator values in the atomspace.
(:update-modulator (-> Symbol Number Expression))
(= (update-modulator $modulatorName $modulatorValue)
	(let* (
	       ($modulator (fetch-modulator &modulator-space $modulatorName))
	       ($_ (update-atom &modulator-space $modulator ($modulatorName $modulatorValue)))
	)
	  	()
	)
)


;(: getDemandByName (-> hyperon::space::DynSpace Symbol Demand))
(= (getDemandByName $space $name) (match $space (demand $name $x) (demand $name $x)))

;; This function updates the modulators after retrieving the values from the demand space.
;;============================================================================
;; misc what is the stimulus value here?
;; there are also additinal ubergoals the system has for demand computation
;; I think the best possible thing to do here is to implement them while also 

;(: modulatorUpdaterAgent (-> Demand Demand Demand Expression))
(= (modulatorUpdaterAgent $modulatorSpace $competence-demand $affiliation-demand $energy-demand)

	(let* (
	       	($stimulus (random-float &rng 0 1))
		    ($integrity (random-float &rng 0 1))
       		((demand competence $competenceValue) $competence-demand)
		    ((demand affiliation $affiliationValue) $affiliation-demand)
		    ((demand energy $energyValue) $energy-demand)
		    ($activationValue (ActivationHelper $competenceValue $energyValue $stimulus))
		    ($securingValue (SecuringThresholdHelper $integrity $stimulus))
		    ($selectionValue (SelectionThresholdHelper $competenceValue $stimulus))
		    ($activationModulator (fetch-modulator $modulatorSpace arousal))
		    ($securingModulator (fetch-modulator $modulatorSpace securing-threshold))
		    ($selectionModulator (fetch-modulator $modulatorSpace selection-threshold))
		    ($_ (update-atom $modulatorSpace $activationModulator (modulator arousal $activationValue)))
		    ($_ (update-atom $modulatorSpace $securingModulator (modulator securing-threshold $securingValue)))
		    ($_ (update-atom $modulatorSpace $selectionModulator (modulator selection-threshold $selectionValue)))
	
 	)
	  ()


	)
)
; I think we need the kb initializer for this to work.
(: kb-initializer (-> hyperon::space::DynSpace Expression))
(= (kb-initializer $kb)
   (let* (
	  	($rules (collapse (get-atoms &rule-space)))
		($modulators (collapse (get-atoms &modulator-space)))
		($demands (collapse (get-atoms &demandspace)))
		($partialKb (union-atom $rules $modulators))
		($kbExp (union-atom $partialKb $demands))
		($_ (collapse (add-atoms $kb $kbExp)))
	)
     		()
    
	)
)

;; The following is a function that is used to calculate a single value metric.
(: calcMetric (-> Expression Expression))
(= (calcMetric $rule)
	(let* (
	       	($stv (extractTvFromRule $rule))
		($mean (cogTvMean $tv))
	       )
	  ($rule $mean)
	)	
)
;; The main loop of the OpenPsi code base will consist of the following
;; The number of cycles which can be a big number or an infinite loop
;; functions that initialize the agents or the agents themselves
;; The knowledge base which is accessed by the agents (atomspace).
;; What structure does the agents have? 
;; representations in openpsi will have the following function arguments
;; The perception updater: (perceptionUpdater $cacheSpace $percepta $max-recur)
;; The action planner: (planner $ruleSpace $initState $goal)
;; The action planner v2: (hillClimbingPlanner $initialState $testedAction $plan $ruleSpace)
;; The feeling updater will have the following function call mechanism
;; The last schema is required to get the next state of the agent.
;; So the action selector agent should return that schema or should be searched by an alternative function
;; This fails if there are multiple cognitive schemas for one actions. There is a possibility for selecting the wrong rule while searching by action.
;; But can't that be prevented by leveraging the calculated heuristic?
;; How can we use the demand updater agent in this usecase?
;; I'm assuming the following functions are implemented fetchDemand or its equivalent fetch-modulator emotion-calculator.
;; How will the demand-updation process will be incorporated to the psi-agent-loop
;; In this case the best option would be to define a decoy updater that might emulate the demand updater agent 
;; Which is friendly with the action and goal selection
;;(feeling_calculator $activation_indicator 
;;                      $resolution_indicator 
;;                     $securing_threshold_indicator 
;;                       $selection_threshold_indicator 
;;                       $pleasure_indicator 
;;                       $number_of_used_modulators)

(: psi-agent-loop (-> Symbol hyperon::space::DynSpace Expression)) 
(= (psi-agent-loop $state $kb)
	(let* (
	    ($demands (queryAll $kb demand))
        ($_ (println! (demands $demands)))
		($currDemand (demandSelector $demands))
        ($_ (println! (dmSelector $currDemand)))
        ($goalObj (goalSelector $currDemand))
		((Goal $goal $goalVal1 $goalVal2) $goalObj) 
        ($_ (println! (goal-psi $goal)))
		($actions (planner &ruleSpace $state $goal))
        ($_ (println! (actions-psi-to-apply $actions goal $goal demand $currDemand)))
		($applyValue (applyActions $actions $goalObj $currDemand)) 
        ($_ (println! (applyValue $applyValue)))
		($competenceDemand (getDemandByName &demandspace competence)) 
        ($_ (println! (competence-psi $competenceDemand)))
		($affiliationDemand (getDemandByName &demandspace affiliation))
		($energyDemand (getDemandByName &demandspace energy))
    
        ($_ (println! (demandValues $competenceDemand $affiliationDemand $energyDemand)))
		($modUpdate (modulatorUpdaterAgent &modulator-space $competenceDemand $affiliationDemand $energyDemand))

        ($_ (println! (modUpdate $modUpdate modulatorValues (collapse (get-atoms &modulator-space))))) 
		($happinessValue (happinessFeelingUpdater &modulator-space))
        ;($_ (println! (happinessVal $happinessValue)))
		($sadnessValue (sadnessFeelingUpdater &modulator-space))
        ;($_ (println! (sadnessVal $sadnessValue)))
		($angerValue (angerFeelingUpdater &modulator-space))
        ;($_ (println! (angerVal $angerValue)))
		($fearValue (fearFeelingUpdater &modulator-space))
		($excitementValue (excitementFeelingUpdater &modulator-space))
		($loveValue (loveFeelingUpdater &modulator-space))
		($hateValue (hateFeelingUpdater &modulator-space))
		($gratitude (gratitudeFeelingUpdater &modulator-space))
        ;($_ (println! (happinessValue $happinessValue angerValue $angerValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue)))
		

	)
	  (hateValue $hateValue happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue)
	 ;;(happinessValue $happinessValue) 
	)	

)
;!(get-atoms &demandspace) 
;!(get-type (demand competence 0.5)) 
;!(get-atoms &modulator-space)
!(getDemandByName &demandspace competence)
;!(fetch-modulator &modulator-space securing-threshold) 
;;!(modulatorUpdaterAgent (demand competence 0.5) (demand affiliation 0.5) (demand energy 0.5))
!(addRulesToSpace &ruleSpace)
!(kb-initializer &kb) 
!(this is a demand)
!(queryAll &kb modulator)
;;!(query &kb (modulator $x $y))
;!(this is the result)
;;!(get-atoms &kb)
;;!(applyActions (approach interact report) (Goal mission_complete 1.0 1.0) (demand competence 0.5))
!(psi-agent-loop init &kb)
;!(happinessFeelingUpdater &modulator-space)
;;!(isGoalMet? (report) (Goal mission_complete 1.0 1.0))
;;!(get-atoms &modulator-space)
;;!(happinessFeelingUpdater)	
;;!(goalSelector (demand Affiliation 2))
;;!(demandSelector ((demand Affiliation 3) (demand Concept 4) (demand Car 8)))
