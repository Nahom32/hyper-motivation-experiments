(: Action Type)
(: Context Type)
(: Implication Type)
(: TemporalTruthValue Type)
(: TruthValue Type)
(: IMPLICATION_LINK (-> Atom Atom Implication))
(: TTV (-> Number TruthValue TemporalTruthValue))
(: STV (-> Number Number TruthValue))
(: context Expression Context)
(: GoalValue Type)

(: Goal (-> Number Number GoalValue))
(: action (-> Symbol Action))
(: rule (-> TemporalTruthValue Context Action Goal))


;;; ===========================================================
;;;             Some Experiments with the New Representation
;;; ===========================================================
(: r (Goal 0.3 0.4))

!(get-type r)
;;!(get-type (get-type r))

(: retrieveType (-> Symbol Symbol))
(= (retrieveType $var)
    (let $r (get-type $var) (get-type $r))
)
;; !(let $r (get-type r) (get-type $r))
!(retrieveType r)