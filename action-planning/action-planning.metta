(= (getLagScm $rule) 1.0) ;;a decoy function that simulates the lead and lag operations.
(: getTotalLag (-> Expression Number))
(= (getTotalLag $list)
    (if (== $list ())
        0
        (let ($head $tail) (decons-atom $list) ((+ (getLagScm $head) (getTotalLag $tail))))
    )
)

(= (meet $list $expiry) (let $totalLag (getTotalLag $list) (<= $totalLag $expiry)))

