!(bind! &space (new-space))
(: fromNumber (-> Number Expression))
(= (fromNumber $x) (if (< $x 1) Z (S (fromNumber (- $x 1)))))
(: Rule (-> Succ 
            (-> 
                (Num $x)))
                )
;;Rules for the backward chainer

!(bind! &space (new-space))
!(fromNumber 10)

(: bc (-> Expression Expression Expression))
(= (bc $kb (: $prf $thm))
	(let ($prf $x) (match $kb (: $prf $thm) (if (== $prf ()) (empty) (: $prf $thm)))
		(bc $kb (: $prf $x)))
)
(: bc (-> Expression Expression Expression))
(= (bc $kb (: $prf $thm $pred))
	(let ($prf $x $y) (match $kb (: $prf $thm $pred) (if (or (== $prf ()) (== $pred ())) (empty) (: $prf $thm $pred)))
		(bc $kb (: $prf $x $y))))
	
!(fromNumber 10)
!(fromNumber 10)
