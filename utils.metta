(: fuzzy-equal (-> Number Number Bool))
(= (fuzzy-equal $op1 $op2)
    (if (<= (abs-math (- $op1 $op2)) 0.01) True False)
)
(: New (superpose (Number Expression Symbol)))
(: New shit)
!(get-type New)
(= (any' $list)
    (let $elem (superpose $list) 
        (if (== $elem True)
            True
            Empty
        )
    )
)
(= (any $list)
    (let $val (collapse (any' $list))
        (if (== $val ()) False True)
    )
)
;; This function works like isInstance in other languages
;; like python. It checks if it is an instance of a type
(= (isType $data $type)
    (let* (
        ($data-types (collapse (get-type $data)))
        ($isType (collapse (== (superpose $data-types) $type)))
        ($data-type (any $isType))
    )
        
        $data-type
    )
    

)
;; !(get-type New)
!(isType New data)
;; (= (if (isType data Symbol)
;; ))
;; !(any (False False False False))


;; !(fuzzy-equal 3.2 3.1)

;; !(get-type True)