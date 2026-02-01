
!(import! &self ../rule-ops.metta)
(PRICE_TABLE A)
(PRICE_TABLE B)
(PRICE_TABLE C)


(PLANET_A (FOOD 8))
(PLANET_A (METAL 15))
(PLANET_A (FUEL 25))

(PLANET_B (FOOD 8))
(PLANET_B (METAL 15))
(PLANET_B (FUEL 25))

(PLANET_C (FOOD 8))
(PLANET_C (METAL 15))
(PLANET_C (FUEL 25))

(AVERAGE_COST FOOD 13)
(AVERAGE_COST METAL 15)
(AVERAGE_COST FUEL 16)


(TRAVEL_COST PLANET_A PLANET_B 1)
(TRAVEL_COST PLANET_B PLANET_C 1)
(TRAVEL_COST PLANET_C PLANET_A 1)

(TRAVEL_COST PLANET_B PLANET_A 1)
(TRAVEL_COST PLANET_C PLANET_B 1)
(TRAVEL_COST PLANET_A PLANET_C 1)

(= (getTravelCost $placeA $placeB)
    (match &self (TRAVEL_COST $placeA $placeB $weight) $weight))


(= (getItemCost $item $place)
    (match &self ($place ($item $value)) $value)
)

(= (getPrice $planet $good)
    (match &self ($planet ($good $value)) $value)
)

(= (extractSourcePlanet $rule) 
    (let* (
        ($context (extractRule Context $rule))
        ($_ (println! (context $context)))
        ;;(($internalContext) $context)
        ($planetInfo (car-atom $context))
        (($planet $planetStv) $planetInfo)
    )
      $planet
  )
)

(= (extractDestinationPlanet $rule) 
    (let* (
        ($goal (extractRule Goal $rule))
        ($_ (println! (goal $goal)))
        ($destinationPlanetInfo (car-atom $goal))
        (($destPlanet $destStv) $destinationPlanetInfo)
    )
      $destPlanet
    )
)
!(extractSourcePlanet  (: Rule 6
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_C (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (TRAVEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
        )))
)))


(= (executeRule $rule $money)
  (let $action (extractRule Action $rule)
        (case $action (
          ((TRAVEL) (let* (
              ($sourcePlanet (extractSourcePlanet $rule))
              ($_ (println! (sourcePlanet $sourcePlanet)))
              ($destPlanet (extractDestinationPlanet $rule))
              ($_ (println! (destinationPlanet $destPlanet)))
              ($travelCost (getTravelCost $sourcePlanet $destPlanet))
              (println! (travelCost $travelCost))
              ($newMoney (- $money $travelCost))
              ($newContext $destPlanet)
           )
              ($newMoney $newContext)
           ))
          

          ((BUY) (let* (
                ($item (extractItem $rule))
                ($planet (extractPlanet $rule))
                ($itemPrice (getPrice $planet $rule))
                ($netMoney (- $money $itemPrice))
              )
              ($netMoney $planet)
              
              ))
          
          ((SELL) (let* (
                ($item (extractItem $rule))
                ($planet (extractPlanet $rule))
                ($itemPrice (getPrice $planet $rule))
                ($netMoney (+ $money $itemPrice))
              )
              ($netMoney $planet)
              
              ))
        ))
  )
)
;;TODO do we need the state here?
;;(= (executeRule $rule $context)
;;    (let $action (extractRule Action $rule)
;;        (if (== $action travel)
;;           (let* (
;;              ($sourcePlanet (extractSourcePlanet $rule))
;;              ($destPlanet (extractDestinationPlanet $rule))
;;              ($travelCost (getTravelCost $sourcePlanet $destPlanet))
;;              ($money (extractMoney $context))
;;              ($newMoney (- $money $travelCost))
;;              ($newContext $destPlanet)
;;           )
;;              ($newMoney $newContext)
;;           )
;;           (if (== $action buy)
;;              (let* (
;;                ($item (extractItem $rule))
;;                ($planet (extractPlanet $rule))
;;                ($itemPrice (getPrice $planet $rule))
;;                ($money (extractMoney $context))
;;                ($netMoney (- $money $itemPrice))
;;              )
;;              ($netMoney $planet)
;;              
;;              )
;;           )
;;        )
;;    )
;;)


;; TODOS
;;extractItem
;;extractPlanet
;;
;;(= (extractMoney $context)
;;    ()
;;)

!(extractRule Context (: Rule 23
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_B (STV 0.2 0.1))
                (HAS_FUEL (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_FUEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
        )))
)))

!(executeRule (: Rule 6
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_C (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (TRAVEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
        )))
)) 56)
