(= (getPlanetFromContexts $contexts) (
    let* (
        (($head $tail) (decons-atom $contexts))
        (($data $stv) $head)
        ($contextType (index-atom $data 0))
        ($contextValue (index-atom $data 1))
    ) (if (== $contextType PLANET)
        $contextValue
        (getPlanetFromContexts $tail)
    ))
)

(= (isValidRule $contexts $money $rule) (
    let* (
        ($ruleContext (eval (extractRule ContextValues $rule)))
        ($ruleActions (eval (extractRule Action $rule)))
        ($currPlanet (getPlanetFromContexts $contexts))
        ($rulePlanet (getPlanetFromContexts $ruleContext))
    ) 
    (if (not (== $currPlanet $rulePlanet)) 
        False
        (isValidActions $rule $ruleActions $contexts $money)
    )
))

(= (isValidActions $rule $actions $contexts $money) (
    if (== $actions ())
        True
        (let* (
            (($head $tail) (decons-atom $actions))
            ($isValid (isValidSingleAction $rule $head $contexts $money))
            (($newContexts $newMoney) (applySingleAction $rule $head $contexts $money))
            ($isValid2 (if $isValid (isValidActions $rule $tail $newContexts $newMoney) False))
        ) $isValid2
              
        )
))

(= (isValidSingleAction $rule $action $contexts $money) (
    let* (
        ($actionType (index-atom $action 0))
        ($currPlanet (getPlanetFromContexts $contexts))
    ) (case $actionType (
            (TRAVEL (
                let* (
                    ($cost 1)
                ) (if (> $cost $money)
                    False
                    True
                )
            ))

            (SELL (
                let* (
                    ($item (index-atom $action 1))
                    (($foundName $stv) (getItem $contexts $item))
                ) (if (== $item $foundName)
                    True
                    False
                )
            ))

            (BUY (
                let* (
                    ($item (index-atom $action 1))
                    ($itemPrice (eval (getItemPrice $item $currPlanet)))
                ) (if (>= $money $itemPrice ) 
                    True
                    False
                )
            ))
    ))
))

(= (getApplicableRules $contexts $money $rules) (
    if (== () $rules)
        ()
        (let* (
            (($head $tail) (decons-atom $rules))
            ($isValid (isValidRule $contexts $money $head))
            ($rest (getApplicableRules $contexts $money $tail))
        ) (if $isValid
            (cons-atom $head $rest)
            $rest
        ))
))

(= (updatePlanet $contexts $planet) (
    if (== $contexts ())
        ()
        (let* (
            (($head $tail) (decons-atom $contexts))
            (($data $stv) $head)
            ($contextType (index-atom $data 0))
            ($rest (updatePlanet $tail $planet))
        ) (if (== $contextType PLANET)
            (cons-atom ((PLANET $planet) $stv) $rest)
            (cons-atom $head $rest)
        )))
)

(= (addItem $contexts $newItem $newStv) (
    if (== $contexts ())
        (cons-atom ((HAS $newItem) $newStv) ())
        (let* (
            (($head $tail) (decons-atom $contexts))
            (($data $stv) $head)
            ($rest (addItem $tail $newItem $newStv))
        ) (if (== $data (HAS $newItem))
            $rest
            (cons-atom $head $rest)
        ))
))

(= (removeItem $contexts $item) (
    if (== $contexts ())
        ()
        (let* (
            (($head $tail) (decons-atom $contexts))
            (($data $stv) $head)
            ($contextType (index-atom $data 0))
            ($contextValue (index-atom $data 1))
            ($rest (removeItem $tail $item))
        ) (if (and (== $contextType HAS) (== $contextValue $item))
            $rest
            (cons-atom $head $rest)
        ))
))

(= (applyTravel $rule $contexts $money) (
    let* (
        ($ruleGoal (eval (extractRule GoalValues $rule)))
        ($source (getPlanetFromContexts $contexts))
        ($destination (getPlanetFromContexts $ruleGoal))
        ($cost 1)
        ($newContext (updatePlanet $contexts $destination))
        ($newMoney (- $money $cost))
    ) ($newContext $newMoney)
))

(= (applySell $rule $contexts $money) (
    let* (
        ($ruleActions (eval (extractRule Action $rule)))
        ($item (index-atom (car-atom $ruleActions) 1))
        ($planet (getPlanetFromContexts $contexts))
        ($newContext (removeItem $contexts $item))
        ($newMoney (+ $money (eval (getItemPrice $item $planet))))
    ) ($newContext $newMoney)
))

(= (applyBuy $rule $contexts $money) (
    let* (
        ($ruleGoal (eval (extractRule GoalValues $rule)))
        (($item $stv) (getItem $ruleGoal))
        ($planet (getPlanetFromContexts $contexts))
        ($itemPrice (eval (getItemPrice $item $planet)))
        ($newContext (addItem $contexts $item $stv))
        ($newMoney (- $money $itemPrice))
    ) ($newContext $newMoney)
))

(= (applySingleAction $rule $action $contexts $money) (
    let* (
        ($actionType (index-atom $action 0))
        ; ($_ (println! ("Action Type" $actionType)))
    ) (case $actionType (
        (TRAVEL (applyTravel $rule $contexts $money))
        (SELL (applySell $rule $contexts $money))
        (BUY (applyBuy $rule $contexts $money))
    ))
))

(= (applyActions $rule $actions $contexts $money) (
    if (== $actions ())
        ($contexts $money)
        (let* (
            (($head $tail) (decons-atom $actions))
            (($newContexts $newMoney) (applySingleAction $rule $head $contexts $money))
        ) (applyActions $rule $tail $newContexts $newMoney))
))

(= (applyRule $rule $contexts $money) (
    let $actions (eval (extractRule Action $rule))
    (applyActions $rule $actions $contexts $money)
))

(= (getItem $contexts) (
    if (== $contexts ())
        (() ())
        (let* (
            (($head $tail) (decons-atom $contexts))
            (($data $stv) $head)
            ($contextType (index-atom $data 0))
            ($itemName (index-atom $data 1))
        ) (if (== $contextType HAS)
            ($itemName $stv)
            (getItem $tail)
        ))
))

(= (getItem $contexts $targetItem) (
    if (== $contexts ())
        (() ())
        (let* (
            (($head $tail) (decons-atom $contexts))
            (($data $stv) $head)
            ($contextType (index-atom $data 0))
            ($itemName (index-atom $data 1))
        ) (if (and (== $contextType HAS) (== $itemName $targetItem))
            ($itemName $stv)
            (getItem $tail $targetItem)
        ))
))



(= (evaluateState $contexts $money) (
    let* (
        (($item $stv) (getItem $contexts))
        ($itemValue (if (== $item ())
            0
            (eval (getAvgPrice $item))
        ))
    ) (+ $itemValue $money)
))

