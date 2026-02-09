(= (isMember $list $val) (
    let $exists (collapse (let $member (superpose $list) (if (== $member $val) True (empty))))
    (if (== $exists ()) 0 1)
))


(= (sum $list) (
    if (== $list ())
        0
        (let* (
            (($head $tail) (decons-atom $list))
            ($rest (sum $tail))
        ) (+ $head $rest))
))


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
