;; The qwestor mainloop should follow the following steps
;; according to gabriels' high level description.
;; The emotion component is not needed.
;; Hence the returned value is the set of actions instead of that the agents should return.
;; So what they should provide is the initial set of parameters but openpsi has its own initialized states.
;; So what should the qwestor agent provide, it should only provide the goal context with other information.

(= (qwestorLoop $contextState)
   (let* (
      ($demands (queryAll $kb demand))
		($currDemand (demandSelector $demands))
    ($goalObj (goalSelector $currDemand))
		((Goal $goal $goalVal1 $goalVal2) $goalObj) 
		($actions (planner &ruleSpace $contextState $goal))
		($applyValue (applyActions $actions $goalObj $currDemand)) 
		($competenceDemand (getDemandByName &demandspace competence)) 
		($affiliationDemand (getDemandByName &demandspace affiliation))
		($energyDemand (getDemandByName &demandspace energy))
    
		($modUpdate (modulatorUpdaterAgent &modulator-space $competenceDemand $affiliationDemand $energyDemand))


   )
    $actions
   ) 
)
