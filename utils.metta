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
        ($data-types (get-type $data))
        ($isType (collapse (== $data-types $type)))
        ;; (() (println! (isType $isType)))
        ($data-type (any $isType))
        (() (println! (get-type $data-type)))
    )
        ;; (if (== $data-type ())
        ;;     False
        ;;     True
        ;; )
        $data-type
    )
    

)
;; !(isType New shit)
!(any (False False False False))


;; !(fuzzy-equal 3.2 3.1)

;; !(get-type True)