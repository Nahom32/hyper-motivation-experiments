
;;Galactic Trader Rules
(= (addWorldRules $space) (
    let $rule (superpose (  
        ;; Travel A -> B
        (: Rule 1
            (TTV 0)
            (STV 0.5 0.002)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context (STV 0.2 0.1) (AND (
                        ((PLANET A) (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND ((TRAVEL))))
                )
                (Goal (STV 0.2 0.1) (AND (
                    ((PLANET B) (STV 0.2 0.1))
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
                        ((PLANET A) (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND ((TRAVEL))))
                )
                (Goal (STV 0.2 0.1) (AND (
                    ((PLANET C) (STV 0.2 0.1))
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
                        ((PLANET B) (STV 0.2 0.1))
                    )))
                    (Action (SEQ_AND ((TRAVEL))))
                )
                (Goal (STV 0.2 0.1) (AND (
                    ((PLANET C) (STV 0.2 0.1))
                )))
        ))

        ; ;; Buy FOOD
        ; (: Rule 7
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (((PLANET A) (STV 0.2 0.1)))))
        ;             (Action (SEQ_AND ((BUY FOOD))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET A) (STV 0.2 0.1))
        ;             ((HAS FOOD) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ; ;; Buy Food in B
        ; (: Rule 8
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (((PLANET B) (STV 0.2 0.1)))))
        ;             (Action (SEQ_AND ((BUY FOOD))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET B) (STV 0.2 0.1))
        ;             ((HAS FOOD) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Buy food at C
        ; (: Rule 9
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (((PLANET C) (STV 0.2 0.1)))))
        ;             (Action (SEQ_AND ((BUY FOOD))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET C) (STV 0.2 0.1))
        ;             ((HAS FOOD) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Buy METAL at A
        ; (: Rule 10
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (((PLANET A) (STV 0.2 0.1)))))
        ;             (Action (SEQ_AND ((BUY METAL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET A) (STV 0.2 0.1))
        ;             ((HAS METAL) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Buy METAL at B
        ; (: Rule 11
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (((PLANET B) (STV 0.2 0.1)))))
        ;             (Action (SEQ_AND ((BUY METAL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET B) (STV 0.2 0.1))
        ;             ((HAS METAL) (STV 0.2 0.1))
        ;         )))
        ; ))


        ; ;; Buy METAL at C
        ; (: Rule 12
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (((PLANET C) (STV 0.2 0.1)))))
        ;             (Action (SEQ_AND ((BUY METAL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET C) (STV 0.2 0.1))
        ;             ((HAS METAL) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ; Buy FUEL at A
        ; (: Rule 13
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET A) (STV 0.2 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((BUY FUEL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET A) (STV 0.2 0.1))
        ;             ((HAS FUEL) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Buy FUEL at B
        ; (: Rule 14
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET B) (STV 0.2 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((BUY FUEL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET B) (STV 0.2 0.1))
        ;             ((HAS FUEL) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Buy FUEL at C
        ; (: Rule 15
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET C) (STV 0.2 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((BUY FUEL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET C) (STV 0.2 0.1))
        ;             ((HAS FUEL) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Sell FOOD at A
        ; (: Rule 16
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET A) (STV 0.2 0.1))
        ;                 ((HAS FOOD) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL FOOD))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET A) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Sell FOOD at B
        ; (: Rule 17
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET B) (STV 0.2 0.1))
        ;                 ((HAS FOOD) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL FOOD))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET B) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Sell FOOD at C
        ; (: Rule 18
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET C) (STV 0.2 0.1))
        ;                 ((HAS FOOD) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL FOOD))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET C) (STV 0.2 0.1))
        ;         )))
        ; ))


        ; ;; Sell METAL at A
        ; (: Rule 19
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET A) (STV 0.2 0.1))
        ;                 ((HAS METAL) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL METAL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET A) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Sell METAL at B
        ; (: Rule 20
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET B) (STV 0.2 0.1))
        ;                 ((HAS METAL) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL METAL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET B) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Sell METAL at C
        ; (: Rule 21
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET C) (STV 0.2 0.1))
        ;                 ((HAS METAL) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL METAL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET C) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Sell FUEL at A
        ; (: Rule 22
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET A) (STV 0.2 0.1))
        ;                 ((HAS FUEL) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL FUEL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET A) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Sell FUEL at B
        ; (: Rule 23
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET B) (STV 0.2 0.1))
        ;                 ((HAS FUEL) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL FUEL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET B) (STV 0.2 0.1))
        ;         )))
        ; ))

        ; ;; Sell FUEL at C
        ; (: Rule 24
        ;     (TTV 0)
        ;     (STV 0.5 0.002)
        ;     (Complexity 1)
        ;     (IMPLICATION
        ;         (AND
        ;             (Context (STV 0.2 0.1) (AND (
        ;                 ((PLANET C) (STV 0.2 0.1))
        ;                 ((HAS FUEL) (STV 0.1 0.1))
        ;             )))
        ;             (Action (SEQ_AND ((SELL FUEL))))
        ;         )
        ;         (Goal (STV 0.2 0.1) (AND (
        ;             ((PLANET C) (STV 0.2 0.1))
        ;         )))
        ; ))
    )) (add-atom $space $rule)
))