!(bind! &kb (new-space))
!(bind! &child-space (new-space))

;; This function removes all occurences of an existing pattern
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
(= (query $space (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))))
   	(collapse (match $space (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal)))
	       (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))))

	))
(= (query $space (Modulator $x $y)) (collapse (match $space (Modulator $x $y)) (Modulator $x $y)))

;; The main loop of the OpenPsi code base will consist of the following
;; The number of cycles which can be a big number or an infinite loop
;; functions that initialize the agents or the agents themselves
;; The knowledge base which is accessed by the agents (atomspace).
;; What structure does the agents have? 
;; The perception updater: (perceptionUpdater $cacheSpace $percepta $max-recur)
;; The action planner: (planner $ruleSpace $initState $goal)
;; The action planner v2: (hillClimbingPlanner $initialState $testedAction $plan $ruleSpace)
;; 
(= (psi-agent $kb $goals $actions))

