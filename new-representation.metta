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
(: Rule Type)
(: HandleSchema Type)
(: handleSchema (-> Symbol Symbol Symbol Symbol HandleSchema))
(: rule (-> TemporalTruthValue Context Action GoalValue Rule))



;; what if I implement two version of the rule?
;; The rule composes itself one at of handles which have different values 
;; But I think there should be a rule for handle naming 
;; There must be some code for naming the handles and truthvalues
;; The first one should be 
;; a smaller name should be used for instance when I name a context variable, 
;; I should use (context exp1 exp2 ....) => c1
;; The ambiguity with this naming convention comes when I name the truthvalue and the temporal truthvalue
;; So I will use 
;;; ===========================================================
;;;             Some Experiments with the New Representation
;;; ===========================================================
(: g1 (Goal 0.3 0.4))
(: c1 (context (csdlfkj cdlkajflk cdlkjfalfkj)))
(: te1 (TTV 1 (STV 0.3 0.4)))
(: a1 (action go))



!(get-type g1)
;;!(get-type (get-type r))

(: retrieveType (-> Symbol Symbol))
(= (retrieveType $var)
    (let $r (get-type $var) (get-type $r))
)
;; !(let $r (get-type r) (get-type $r))
!(retrieveType g1)



(: convertSchemaToRule (-> Atom HandleSchema Rule))
(= (convertSchemaToRule $space $schema)
    (let* (
        ((handleSchema $temporalHandle $contextHandle $actionHandle $goalHandle) $schema)
        
        ($temporalValue (match $space (: $temporalHandle $temporal) $temporal))
       
        ($contextValue (match $space (: $contextHandle $context) $context))
        
        ($actionValue (match $space (: $actionHandle $action) $action))
        ;; ($_ (println! (temp $actionValue)))
        ($goalValue (match $space (: $goalHandle $goal) $goal))
        
    )
        (rule $temporalValue $contextValue $actionValue $goalValue)
    )

)
!(convertSchemaToRule &self (handleSchema te1 c1 a1 g1))
