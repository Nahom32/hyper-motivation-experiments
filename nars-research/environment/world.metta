
!(import! &self ../rule-ops.metta)
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

;;(: Rule 1
;;    (TTV 0)
;;    (STV 0.5 0.002)
;;    (Complexity 1)
;;    (IMPLICATION
;;        (AND
;;            (Context (STV 0.2 0.1) (AND (
;;                (PLANET_A (STV 0.2 0.1))
;;            )))
;;            (Action (SEQ_AND (TRAVEL)))
;;        )
;;        (Goal (STV 0.2 0.1) (AND (
;;            (PLANET_B (STV 0.2 0.1))
;;        )))
;;))

(= (getTravelCost $placeA $placeB)
    (match &self (TRAVEL_COST $placeA $placeB $weight) $weight))


(= (getItemCost $item $place)
    (match &self ($place ($item $value)) $value)
)

(= (getPrice $planet $good)
    (match &self ($planet ($good $value)) $value)
)
(: Rule 6
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
))
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
        ($_ (println! (context $context)))
        ((($planet $stv)) $context)

    )
      $planet
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
(= (executeRule $rule $context $money)
  (let $action (extractRule Action $rule)
        (case $action (
          ((TRAVEL) (let* (
              ($sourcePlanet (extractSourcePlanet $rule))
              ($destPlanet (extractDestinationPlanet $rule))
              ($travelCost (getTravelCost $sourcePlanet $destPlanet))
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
