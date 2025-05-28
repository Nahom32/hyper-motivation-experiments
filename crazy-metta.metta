!(bind! &space (new-space))
(: fromNumber (-> Number Expression))
(= (fromNumber $x) (if (< $x 1) Z (S (fromNumber (- $x 1)))))
(: Rule (-> Succ 
            (-> 
                (Num $x)))
                )
;;Rules for the backward chainer

!(fromNumber 10)
