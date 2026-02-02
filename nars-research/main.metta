(= (addWorldRules $space)
;; Travel A -> B
(let $rules (superpose ((: Rule 1
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_A (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (TRAVEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
        )))
))

;; Travel A -> C
(: Rule 2
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_A (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (TRAVEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_C (STV 0.2 0.1))
        )))
))

;; Travel B -> A
(: Rule 3
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_B (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (TRAVEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_A (STV 0.2 0.1))
        )))
))

;; Travel B -> C
(: Rule 4
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_B (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (TRAVEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_C (STV 0.2 0.1))
        )))
))

;; Travel C -> A
(: Rule 5
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
            (PLANET_A (STV 0.2 0.1))
        )))
))

;; Travel C -> B
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

;; Buy FOOD
(: Rule 7
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND ((PLANET_A (STV 0.2 0.1)))))
            (Action (SEQ_AND (BUY_FOOD)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_A (STV 0.2 0.1))
            (HAS_FOOD (STV 0.2 0.1))
        )))
))

;; Buy Food in B
(: Rule 8
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND ((PLANET_B (STV 0.2 0.1)))))
            (Action (SEQ_AND (BUY_FOOD)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
            (HAS_FOOD (STV 0.2 0.1))
        )))
))

;; Buy food at C
(: Rule 9
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND ((PLANET_C (STV 0.2 0.1)))))
            (Action (SEQ_AND (BUY_FOOD)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_C (STV 0.2 0.1))
            (HAS_FOOD (STV 0.2 0.1))
        )))
))

;; Buy METAL at A
(: Rule 10
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_A (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (BUY_METAL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_A (STV 0.2 0.1))
            (HAS_METAL (STV 0.2 0.1))
        )))
))

;; Buy METAL at B
(: Rule 11
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_B (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (BUY_METAL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
            (HAS_METAL (STV 0.2 0.1))
        )))
))

;; Buy METAL at C
(: Rule 12
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_C (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (BUY_METAL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_C (STV 0.2 0.1))
            (HAS_METAL (STV 0.2 0.1))
        )))
))

;; Buy FUEL at A
(: Rule 13
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_A (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (BUY_FUEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_A (STV 0.2 0.1))
            (HAS_FUEL (STV 0.2 0.1))
        )))
))

;; Buy FUEL at B
(: Rule 14
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_B (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (BUY_FUEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
            (HAS_FUEL (STV 0.2 0.1))
        )))
))

;; Buy FUEL at C
(: Rule 15
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_C (STV 0.2 0.1))
            )))
            (Action (SEQ_AND (BUY_FUEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_C (STV 0.2 0.1))
            (HAS_FUEL (STV 0.2 0.1))
        )))
))

;; Sell FOOD at A
(: Rule 16
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_A (STV 0.2 0.1))
                (HAS_FOOD (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_FOOD)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_A (STV 0.2 0.1))
        )))
))

;; Sell FOOD at B
(: Rule 17
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_B (STV 0.2 0.1))
                (HAS_FOOD (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_FOOD)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
        )))
))

;; Sell FOOD at C
(: Rule 18
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_C (STV 0.2 0.1))
                (HAS_FOOD (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_FOOD)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_C (STV 0.2 0.1))
        )))
))

;; Sell METAL at A
(: Rule 19
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_A (STV 0.2 0.1))
                (HAS_METAL (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_METAL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_A (STV 0.2 0.1))
        )))
))

;; Sell METAL at B
(: Rule 20
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_B (STV 0.2 0.1))
                (HAS_METAL (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_METAL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_B (STV 0.2 0.1))
        )))
))

;; Sell METAL at C
(: Rule 21
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_C (STV 0.2 0.1))
                (HAS_METAL (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_METAL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_C (STV 0.2 0.1))
        )))
))

;; Sell FUEL at A
(: Rule 22
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_A (STV 0.2 0.1))
                (HAS_FUEL (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_FUEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_A (STV 0.2 0.1))
        )))
))

;; Sell FUEL at B
(: Rule 23
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
))

;; Sell FUEL at C
(: Rule 24
    (TTV 0)
    (STV 0.5 0.002)
    (Complexity 1)
    (IMPLICATION
        (AND
            (Context (STV 0.2 0.1) (AND (
                (PLANET_C (STV 0.2 0.1))
                (HAS_FUEL (STV 0.1 0.1))
            )))
            (Action (SEQ_AND (SELL_FUEL)))
        )
        (Goal (STV 0.2 0.1) (AND (
            (PLANET_C (STV 0.2 0.1))
        )))
))
)) (add-atom $space $rules)))

!(addWorldRules &worldSpace)

!(get-atoms &worldSpace)
