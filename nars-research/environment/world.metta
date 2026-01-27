(PRICE_TABLE A)
(PRICE_TABLE B)
(PRICE_TABLE C)


(A (FOOD 8))
(A (METAL 15))
(A (FUEL 25))

(B (FOOD 8))
(B (METAL 15))
(B (FUEL 25))

(C (FOOD 8))
(C (METAL 15))
(C (FUEL 25))

(AVERAGE_COST FOOD 13)
(AVERAGE_COST METAL 15)
(AVERAGE_COST FUEL 16)


(TRAVEL_COST A B 1)
(TRAVEL_COST B C 1)
(TRAVEL_COST C A 1)

(= (getTravelCost $placeA $placeB)
    (match &self (TRAVEL_COST $placeA $placeB $weight) $weight))


(= (getItemCost $item $place)
    (match &self ($place ($item $value)) $value)
)

(= (executeRule $rule $currState)
  (let $action (extractRule Action $rule)
        (case $action (
          (travel (let* (
              ($sourcePlanet (extractSourcePlanet $rule))
              ($destPlanet (extractDestinationPlanet $rule))
              ($travelCost (getTravelCost $sourcePlanet $destPlanet))
              ($money (extractMoney $currState))
              ($newMoney (- $money $travelCost))
              ($newContext $destPlanet)
           )
              ($newMoney $newContext)
           ))
          (buy (let* (
                ($item (extractItem $rule))
                ($planet (extractPlanet $rule))
                ($itemPrice (getPrice $planet $rule))
                ($money (extractMoney $currState))
                ($netMoney (- $money $itemPrice))
              )
              ($netMoney $planet)
              
              ))
          (sell (let* (
                ($item (extractItem $rule))
                ($planet (extractPlanet $rule))
                ($itemPrice (getPrice $planet $rule))
                ($money (extractMoney $currState))
                ($netMoney (+ $money $itemPrice))
              )
              ($netMoney $planet)
              
              ))
        ))
  )
)
;;TODO do we need the state here?
;;(= (executeRule $rule $currState)
;;    (let $action (extractRule Action $rule)
;;        (if (== $action travel)
;;           (let* (
;;              ($sourcePlanet (extractSourcePlanet $rule))
;;              ($destPlanet (extractDestinationPlanet $rule))
;;              ($travelCost (getTravelCost $sourcePlanet $destPlanet))
;;              ($money (extractMoney $currState))
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
;;                ($money (extractMoney $currState))
;;                ($netMoney (- $money $itemPrice))
;;              )
;;              ($netMoney $planet)
;;              
;;              )
;;           )
;;        )
;;    )
;;)
