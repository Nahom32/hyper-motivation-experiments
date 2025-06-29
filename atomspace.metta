!(import! &self demand-functions)
!(import! &self modulator-updaters)
!(bind! &kb (new-space))
!(bind! &modulator-space (new-space))
;;!(bind! &demand-space (new-space))
!(bind! &rule-space (new-space))
!(bind! &cache-space (new-space))
;; Line 2 to Line 5 are expected to be removed.

;; This function removes all occurences of an existing pattern
;; how would we evaluate it? The action is planned, then the demand updater should update based on the plan

;; A function to be removed later on
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





(= (ruleSpace) (&rule-space))
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
;; a querying mechanism of the knowledge base.
(= (query $space (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))))
   	(collapse (match $space (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal)))
	       (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))))

	))
(= (query $space (Modulator $x $y)) (collapse (match $space (Modulator $x $y)) (Modulator $x $y)))
(= (query $space (perception $x $y)) (collapse (match $space (perception $x $y) (perception $x $y))))
(= (query $space (demand $x $y)) (collapse (match $space (demand $x $y) (demand $x $y))))

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

(: demandSelector (-> Expression Demand))
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
		 ((demand Affiliation $y) (Goal terminate 0.4 0.3))
		 
	)
)
)

;; A for the matched llm value
(: matchGoal (-> hyperon::space::DynSpace Expression Expression)) 
(= (matchGoal $ruleSpace $actions)
   	(goal1 context1)
)
(: applyActions (-> Expression Goal Expression))
(= (applyActions $actions $goal $demand) 
   (if (== $actions ())
     		()
		(let $isGoalMet? (isGoalMet? $actions $goal)
		  	(if $isGoalMet? 
			  	(setDemandValue &demandspace $demandName 1.0)
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
(: selectRuleByAction (-> hyperon::space::DynSpace Symbol)) 
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
		  	()
			(selectMaxRule $tail $maxRule)
			(selectMaxRule $tail $rule)

		)
	  	
	)))


(: extractGoalFromRule (-> Expression Goal))
(= (extractGoalFromRule $rule)
	(unify $rule (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $goal ()))

;; This function is taken from the action planner in version 1. It will be removed
(= (findRulesWithAction $space $action)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        
    )))

(:isGoalMet' (-> Expression Goal Bool))
(= (isGoalMet' $rules $goal)
   	(if (== $rules ())
		False
		(let* (
			(($rule $tail) (decons-atom $rules))
			($ruleGoal (extractGoalFromRule $rule))
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
	       ($rules' (findRulesWithAction (ruleSpace) $lastAction)) 
	)
		(isGoalMet' $rules' $goal)
	)	
)
(: modulator-updater-agent (-> Demand Demand Demand Expression))
(= (modulator-updater-agent $competence-demand $affiliation-demand $energy-demand)

(let* (
       	((demand competence $competenceValue) $competence-demand)
	((demand affiliation $affiliationValue) $affiliation-demand)
	((demand energy $energyValue) $energy-demand)

	)

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
(: psi-agent-loop (-> Symbol hyperon::space::DynSpace Expression)) 
(= (psi-agent-loop $state $kb)
	(let* (
	       	($demands (query $kb (demand $x $y)))
		($currDemand (demandSelector $demands))
		($goal (goalSelector $currDemand))
		($actions (planner (ruleSpace) $state $goal))
		($_ (applyActions $actions $goal $currDemand))
		($_ ())
		($_ ())
		($_ ())

	)
	  
	)	

)

!(getAllDemands &demandspace)	
!(goalSelector (demand Affiliation 2))
!(demandSelector ((demand Affiliation 3) (demand Concept 4) (demand Car 8)))
