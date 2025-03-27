(: fuzzy-equal (-> Number Number Bool))
(= (fuzzy-equal $op1 $op2)
    (if (<= (abs-math (- $op1 $op2)) 0.01) True False)
)

!(fuzzy-equal 3.2 3.1)

!(get-type True)