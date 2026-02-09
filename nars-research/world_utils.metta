!(import! &self rule-ops)
!(import! &self world_functions)
(= (getPlanetFromContexts $context) (
    let* (
        ;;($_ (println! (contexts $context)))
        (($head $tail) (decons-atom $context))
        ($contextType (index-atom $head 0))
        ;;($_ (println! (contextType $contextType)))
        ($contextValue (index-atom $head 1))
    ) (if (== $contextType PLANET)
        $contextValue
        (getPlanetFromContexts $tail)
    ))
)

(= (isValidRule $context $money $rule) (
    let* (
        ($ruleContext (extractRule ContextValues $rule))
        ;;($_ (println! (working ruleContext $ruleContext)))
        ($ruleActions (extractRule Action $rule))
        ($ruleGoal (extractRule GoalValues $rule))

        ($ruleAction (car-atom $ruleActions))
        ($_ (println! (ruleAction $ruleAction)))
        ($currPlanet (getPlanetFromContexts $context))
        ;;($_ (println! (currPlanet $currPlanet)))
        ($rulePlanet (getPlanetFromContexts $ruleContext))
        ;;($rulePlanet (car-atom $ruleContext))
        ;;($_ (println! (rulePlanet $rulePlanet)))
        ;;($check (not (== $currPlanet $rulePlanet)))
        ;;($_ (println! (conditionalCheck $check)))
    ) (if (not (== $currPlanet $rulePlanet)) 
        False
        (case $ruleAction (
            (TRAVEL (
                let* (
                    ($source (getPlanetFromContexts $ruleContext))
                    ;;($source (car-atom $ruleContext))
                    ;;($_ (println! (source $source)))
                    ;;($_ (println! (ruleGoal $ruleGoal)))
                    ($destination (getPlanetFromContexts $ruleGoal))
                    ;;($_ (println! (destination $destination)))
                    ($cost (getTravelCost $source $destination))
                    ;;($_ (println! (cost $cost)))
                ) (if (> $cost $money)
                    False
                    True
                )
            ))

            (SELL (
                let* (
                    ($_ (println! (itemsBf $ruleActions)))
                    ($item (index-atom $ruleActions 1))
                    ($_ (print! (sellitem $item)))
                    ($currItem (getItem $context))
                ) (if (== $item $currItem)
                    True
                    False
                )
            ))

            (BUY (
                let* (
                    ($item (getItem $ruleGoal))
                    ($_ (println! (item $item)))
                    ($itemPrice (getItemPrice $item $currPlanet))
                ) (if (>= $money $itemPrice ) 
                    True
                    False
                )
            ))
    ))
)))

(= (getApplicableRules $contexts $money $rules) (
    if (== () $rules)
        ()
        (let* (
            (($head $tail) (decons-atom $rules))
            ($isValid (isValidRule $contexts $money $head))
            ($_ (println! (isValid $isValid)))
            ($rest (getApplicableRules $contexts $money $tail))
            ($_ (println! (rest $rest)))
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
            ($_ (println! (planet $head)))
            ($contextType (index-atom $head 0))
            ($contextValue (index-atom $head 1))
            ($rest (updatePlanet $tail $planet))
            ($_ (println! (rest $rest)))
        ) (if (== $contextType PLANET)
            (cons-atom (PLANET $planet) $rest)
            (cons-atom $head $rest)
        )))
)

(= (addItem $contexts $item) (
    if (== $contexts ())
        (cons-atom (HAS $item) ())
        (let* (
            (($head $tail) (decons-atom $contexts))
            ($contextType (index-atom $head 0))
            ($contextValue (index-atom $head 1))
            ($rest (addItem $tail $item))
        ) (if (== $contextType HAS)
            $rest
            (cons-atom $head $rest)
        ))
))

(= (removeItem $contexts $item) (
    if (== $contexts ())
        ()
        (let* (
            (($head $tail) (decons-atom $contexts))
            ($contextType (index-atom $head 0))
            ($contextValue (index-atom $head 1))
            ($rest (removeItem $tail $item))
        ) (if (== $contextValue $item)
            $rest
            (cons-atom $head $rest)
        ))
))

(= (applyTravel $rule $contexts $money) (
    let* (
        ($_ (println! (TRAVEL BEING APPLIED)))
        ($ruleContext (extractRule ContextValues $rule))
        ($_ (println! (ruleContextTravel $ruleContext)))
        ($ruleGoal (extractRule GoalValues $rule))
        ($source (getPlanetFromContexts $ruleContext))
        ($_ (println! (sourceTravel $source)))
        ($destination (getPlanetFromContexts $ruleGoal))
        ($_ (println! (destinationTravel $destination)))
        ($cost (getTravelCost $source $destination))
        ($_ (println! (costTravel $cost)))
        ($newContext (updatePlanet $contexts $destination)) ;; TODO
        ($newMoney (- $money $cost))
    ) ($newContext $newMoney)
))

(= (applySell $rule $contexts $money) (
    let* (
        ($item (getItem $contexts))
        ($planet (getPlanetFromContexts $contexts))
        ($_ (println! (planetSell $planet)))
        ($newContext (removeItem $contexts $item))
        ($newMoney (+ $money (getItemPrice $item $planet)))
    ) ($newContext $newMoney)
))

(= (applyBuy $rule $contexts $money) (
    let* (
        ($ruleGoal (extractRule GoalValues $rule))
        ($item (getItem $ruleGoal))
        ($planet (getPlanetFromContexts $ruleGoal))
        ($itemPrice (getItemPrice $item $planet))
        ($newContext (addItem $contexts $item))
        ($newMoney (- $money $itemPrice))
    ) ($newContext $newMoney)
))

(= (applyRule $rule $contexts $money) (
    let* (
        ($ruleActions (extractRule Action $rule))
        ($_ (println! (ruleActions $ruleActions)))
        ($ruleAction (index-atom $ruleActions 0))
        ($_ (println! (ruleAction $ruleAction)))
    ) (case $ruleAction (
        (TRAVEL (applyTravel $rule $contexts $money))
        (SELL (applySell $rule $contexts $money))
        (BUY (applyBuy $rule $contexts $money))
    ))
))

(= (getItem $contexts) (
    if (== $contexts ())
        ()
        (let* (
            ($_ (println! (itemContext $contexts)))
            (($head $tail) (decons-atom $contexts))
            ($contextType (index-atom $head 0))
            ($_ (println! (headItem $head)))
            ($itemName (index-atom $head 1))
            ($_ (println! (gItem $itemName)))
        ) (if (== $contextType HAS)
            $itemName
            (getItem $tail)
        ))
))

(= (evaluateState $contexts $money) (
    let* (
        ($_ (println! (stateContexts $contexts)))
        ($item (getItem $contexts))
        ($_ (println! (stateItem $item)))
        ($itemValue (getAvgPrice $item))
        ($_ (evalStateValue $itemValue))
    ) (+ $itemValue $money)
))

(= (updateBeta $alpha $beta $reward) (
    if (== $reward 0) 
        ((+ 1 $alpha) (+ 1 $beta))
        (if (> $reward 0)
            ((+ $alpha $reward) $beta)
            ($alpha (+ $beta $reward))
        )
))

;; (= (updateSTV $rule ($strength $confidence)) (
;;     let* (
;;         ((: Rule $id $ttv (STV $s $c) $comp $impl) $rule)
;;     ) (: Rule $id $ttv (STV $strength $confidence) $comp $impl)
;; ))

;; (= (updateRule $selectedRule $reward) (
;;     let* (
;;         ((STV $s $c) (extractRule STV $selectedRule))
;;         (($alpha $beta) (stvToBeta ($s $c)))
;;         (($newAlpha $newBeta) (updateBeta $alpha $beta $reward))
;;         (($newStrength $newConfidence) (betaToSTV $newAlpha $newBeta))
;;         ($newRule (updateSTV $selectedRule ($newStrength $newConfidence)))
;;     ) $newRule
;; ))

;; Update Atoms in a space
;;(: updateAtom (-> Grounded Atom Atom (->)))
;;(= (updateAtom $oatom $natom $space) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))
