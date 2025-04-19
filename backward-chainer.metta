

;; a backward chainer which searchs a knowledge space given a goal.
(= (bc $kb ($context $action $goal) $accum)
    (let* (
        ($data (match $kb ($x $y $context)))
        ($newAccum (cons-atom $accum $goal))
    )
        (if (== $x init)
            $accum
            (bc $kb $data $newAccum)
        )
    )
)