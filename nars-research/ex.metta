!(subtraction-atom (a b c d) (a c d e))
!(div 6 2)
!(add-atom &n 2)
!(get-atoms &n)
!(remove-atoms &n)
!(get-atoms &n)

(= (add-atoms $space $atoms) 
    (if (== (size-atom $atoms) 0) 
        ()
        (let* (
            ;;(($head $tail) (decons-atom $atoms))
            ($head (car-atom $atoms))
            ($tail (cdr-atom $atoms))
            ($_ (add-atom $space $head))
        )
            (add-atoms $space $tail)
        )
    )
)


!(add-atoms &n (1 2 3 4 5))
!(collapse (get-atoms &n))
