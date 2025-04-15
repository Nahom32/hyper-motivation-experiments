!(let* (
    (($x $y $z) $ada)
    (X $x)
    ($y Y)
    ($z Z)
)
    $ada
)
;; (= (AndLink $val1 $val2)
;;   (if (and (== $val1 True) (== $val2 True))
;;     True
;;     False ;; First condition is False
;;   )
;; )

;; (= (context-thirsty)
;;   (EvaluationLink
;;     (PredicateNode "is-thirsty")         ;; Predicate: The agent is thirsty.
;;     (ListLink (ConceptNode "agent"))     ;; Argument: The agent itself.
;;   )
;; )
;; !(context-thirsty)