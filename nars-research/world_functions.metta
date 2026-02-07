;; Travel Info
(TRAVEL_COST A B 1)
(TRAVEL_COST A C 1)
(TRAVEL_COST B A 1)
(TRAVEL_COST B C 1)
(TRAVEL_COST C A 1)
(TRAVEL_COST C B 1)


(FOOD A 8)
(FOOD B 20)
(FOOD C 18)

(METAL A 15)
(METAL B 8)
(METAL C 22)

(FUEL A 25)
(FUEL B 18)
(FUEL C 5)

(AVG_PRICE FOOD 15)
(AVG_PRICE METAL 15)
(AVG_PRICE FUEL 16)

;; Helper Functions
(= (getTravelCost $source $destination) (
    match &self (TRAVEL_COST $source $destination $cost) $cost
))

(= (getFoodCost $planet) (
    match &self (FOOD $planet $cost) $cost
))

(= (getMetalCost $planet) (
    match &self (METAL $planet $cost) $cost
))

(= (getFuelCost $planet) (
    match &self (FUEL $planet $cost) $cost
))

(= (getItemPrice $item $planet) (
    match &self ($item $planet $price) $price
))

(= (getAvgPrice $item) (
    match &self (AVG_PRICE $item $price) $price
))