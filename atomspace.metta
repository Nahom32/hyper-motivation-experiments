!(bind! &kb (new-space))
!(bind! &modulator-space (new-space))
!(bind! &demand-space (new-space))
!(bind! &rule-space (new-space))


;; This function removes all occurences of an existing pattern
;; how would we evaluate it? The action is planned, then the demand updater should update based on the plan
(= (ruleSpace) (&rule-space))
(= (modulatorSpace) (&modulator-space))
(= (demandSpace) (&demand-space))
(= (add-atoms $space $values)
	(add-reduct $space (superpose $values)))
(= (remove-occurrences $space $pattern)
   	(let $atoms (collapse (match $space $pattern $pattern))
	  	(remove-atoms $space $atoms)))

(= (update-atoms $pattern $updater $updated)
   	(let* (
	       ($updater-atoms (collapse (get-atoms $updater)))
	       ($_ (remove-occurrences $updated $pattern))
		($_ (collapse (add-atoms $space $updated)))
	       )
	  	
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


(= (demandSelector' $demands $maxDemand)
   	(if (== $demands ()) 
	  	$maxDemand
		(let* (
		       	((demand $maxName $maxVal) $maxDemand)
		       	(((demand $currName $currVal) $tail) (decons-atom $demands))
		       )
		  	(if (> $currVal $maxVal)
			  	(demandSelector' $tail (demand $currName $currVal))
				(demandSelector' $tail $maxDemand)
			)
		)
	)
)
;; A one to one relationship between a demand and a goal.
;; This goal selector maps from the demand and applies the goal to it
(= (goalSelector $demand)
   (case $demand(
		 ((demand Affiliation $y) (Goal $x $y))
		 )))
(= (applyActions $actions)
        (if (== $actions ())
     		()

	
	)
)
(= (demandSelector $demands)
   	(if (== $demands ())
	  	(Error "No Demands Available")
		(demandSelector' $demands (car-atom $demands))))
;; A non-deterministic implementation of demand selection refer 
;; OpenPsi: A Novel Computational Affective Model and its Application in Video Games by Goertzel,Ben et. al (2013)
(: selectDemand (-> Expression Expression))
(= (selectDemand $demands)
   (let* (
	  ($selectionVal (fetch-modulator-val (modulatorSpace) selection-threshold))
	  ($randomVal (random-float 0 1))
	)
     	(if (> $selectionVal $randomVal)
	  	(demandSelector $demands)
		(let* (
			($length (size-atom $demands))
			($randIndex (random-int 0 (- $length 1)))
			($demand (index-atom $deamnds $randIndex))
		)
		  $demand))))


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
(= (psi-agent-loop $state $kb)
	(let* (
	       	($demands (query $kb (demand $x $y)))
		($currDemand (demandSelector $demands))
		($goal (goalSelector $currDemand))
		($actions (planner (ruleSpace) $state $goal))
		($resolutionVal (fetch-modulator-val (modulatorSpace) resoultion)
		($_ (applyActions $actions))

	)
	  ()
	)	

)
	


