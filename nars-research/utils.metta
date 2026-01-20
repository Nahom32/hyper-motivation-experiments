(: countSimilar (-> Expression Expression Number))
(= (countSimilar $listOne $listTwo) (
    let* (
        ($count (collapse (let $value (superpose $listOne) (let $isIn (isMember $listTwo $value) $isIn))))
    ) (sum $count)
))

(= (areSimilar $listOne $listTwo) 
    (if (not (== (size-atom $listOne) (size-atom $listTwo)))
        False
        (if (== (size-atom $listOne) (countSimilar $listOne $listTwo))
            True 
            False)
))

(= (clearSpace $space)
  (match $space $atom
    (remove-atom $space $atom)
  )
)

(: min (-> Number Number Number))
(= (min $num1 $num2) (
    if (< $num1 $num2)
        $num1
        $num2
))

(: div (-> Number Number Number))
(= (div $num $denom) (
    (py-atom operator.truediv) $num $denom
))

(: round (-> Number Number Number))
(= (round $num $sig) ((py-atom round) $num $sig))
