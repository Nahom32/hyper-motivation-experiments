; %%%% Hyperon-Experimental compatibility library. %%%%
; Many of the included functions were considered ad hoc and
; straightforward to express directly in MeTTa itself:

;Equality and Reduction
(= (if-equal $A $B $Then $Else)
   (if (== $A $B) $Then $Else))

(= (if-equal2 $A $B $Then $Else)
   (if (== $A $B) $Then $Else))
(= (cadr-atom $atom)
    (let $interim (cdr-atom $atom) (car-atom $interim))
)

(= (assertEqual $A $B)
   (assert (== $A $B)))

(= (assertAlphaEqual $A $B)
   (assert (=alpha $A $B)))

(: unify (-> Expression Expression Expression Expression %Undefined%))

(= (unify $space $pattern $then $else)
   (if (is-space $space)
       (let $temp (cut)
            (case (match $space $pattern $pattern)
                  (($pattern $then)
                   (Empty $else)))) (empty)))

(= (unify $a $b $then $else)
   (if (= $a $b)
       (eval $then)
       (eval $else)))

(: add-reduct (-> %Undefined% Expression Bool))
(= (add-reduct $space $f)
   (let* (($headbody (cdr-atom $f))
          ($head (car-atom $headbody))
          ($body (cdr-atom $headbody))
          ($bodyreduced (eval $body)))
         (add-atom $space (= $head $bodyreduced))))

;Error Handling
(= (if-error $X $A $B)
   (if (= $X (cons Error $_)) 
       $A $B))

(= (return-on-error $result $B)
   (if-error $result
             $result
             $B))

;Evaluation control
(= (for-each-in-atom $L $f)
   (map-atom $L $f))

(: evalc (-> Expression %Undefined% %Undefined%))
(= (evalc $expression &self)
   (eval $expression))

;Quoting
(: unquote (-> Expression %Undefined%))
(= (unquote (quote $A))
   (let $cut (cut) (eval $A)))
(= (unquote $A) (quote (unquote $A)))

(: noreduce-eq (-> Expression Expression Bool))
(= (noreduce-eq $A $B)
   (== $A $B))

;Types
(= (is-function (-> $A $B)) (let $temp (cut) True))
(= (is-function $X) False)

(= (get-type-space &self $x)
   (get-type $x))

(= (match-types $A $B $Then $Else)
   (if (== $A $B) $Then $Else))

(= (match-type-or $value $type1 $type2)
   (match-types $type1 $type2 True $value))

(= (extractRule $section $rule) (
    case $section (
        (Id (extractRuleId $rule))
        (TTV (extractRuleTTV $rule))
        (STV (extractRuleSTV $rule))
        (AllContext (extractAllContext $rule))
        (Context (extractRuleContext $rule))
        (ContextSTV (extractRuleContextSTV $rule))
        (ContextValues (extractRuleContextValues $rule))
        (Action (extractRuleAction $rule))
        (ContextAndAction (extractContextAndAction $rule))
        (AllGoal (extractAllGoal $rule))
        (Goal (extractRuleGoal $rule))
        (GoalSTV (extractRuleGoalSTV $rule))
        (GoalValues (extractRuleGoalValues $rule))
        ($default ())
    )
))
(= (matchGoals $goals $rules) (
    if (== $rules ())
        ()
        (let* (
            (($rule $restRules) (decons-atom $rules))
            ($rule-goal (extractRule GoalValues $rule))
            ($restMatching (matchGoals $goals $restRules))
        ) (if (sameElements $goals $rule-goal)
            (cons-atom $rule $restMatching)
            $restMatching
        ))
))

(= (sameElements $list1 $list2) (
    if (not (== (size-atom $list1) (size-atom $list2)))
        False
        (let $intersection (intersection-atom $list1 $list2) (== (size-atom $intersection) (size-atom $list1)))      
))

(= (matchContexts $rules $contexts) (
    if (== $rules ())
        ()
        (let* (
            (($rule $restRules) (decons-atom $rules))
            ($rule-context (extractRule ContextValues $rule))
            ($restMatching (matchContexts $restRules $contexts))
        ) (if (sameElements $contexts $rule-context)
            (cons-atom $rule $restMatching)
            $restMatching
        ))
))


(: extractRuleId (-> Expression Number))
(= (extractRuleId $rule) (
    unify (: Rule $id $ttv $stv $complexity $implication) $rule
        $id
        -1
))

(: extractRuleTTV (-> Expression Number))
(= (extractRuleTTV $rule) (
    unify (: Rule $id (TTV $ttv) $stv $complexity $implication) $rule
        $ttv
        -1
))

(= (extractRuleContext $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION (AND (Context $context-stv (AND $context)) $action) $goal))
      $rule
      $context
      Empty         
))

(= (extractRuleContextValues $rule) (
    let $contexts (extractRuleContext $rule) (map-atom $contexts $context ((car-atom $context) (cadr-atom $context)))
))

(= (extractRuleAction $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION (AND $context (Action (SEQ_AND $action))) $goal)) $rule
        $action
        $rule
))

(= (extractRuleGoal $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION $and-link (Goal $goal-stv (AND $goal)))) $rule
        $goal
        Empty
))

(= (extractRuleGoalValues $rule) (
    let $goals (extractRuleGoal $rule) (map-atom $goals $goal ((car-atom $goal) (cadr-atom $goal)))
))

(= (extractRuleSTV $rule) (
    unify (: Rule $id $ttv (STV $s $c) $complexity $implication) $rule
        (STV $s $c)
        (STV 1 0)
))

(= (extractRuleContextSTV $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION (AND (Context $cont-stv $contexts) $actions) $goal)) $rule
        $cont-stv
        (STV 1 0)
))

(= (extractRuleGoalSTV $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION (AND $context $action) (Goal $goal-stv $goals))) $rule
        $goal-stv
        (STV 1 0)
))

(= (extractContextAndAction $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION $contextAction $goal)) $rule
        $contextAction
        empty
))

(= (extractAllGoal $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION $contextAction $goal)) $rule
        $goal
        empty
))

(= (extractAllContext $rule) 
(unify (: Rule $id $ttv $stv $complexity (IMPLICATION (AND $context $action) $goal)) $rule
        $context
       empty
))

;; General Rule helpers

;; For now complexity is the number of actions in the rule
(: calculateComplexity (-> Expression Number))
(= (calculateComplexity $rule) (
    let* (
        ($action (extractRuleAction $rule))
        ($actionCount (size-atom $action))
    ) $actionCount
))

;; This could be optimized by adding an atom that tracks the max TTV in the rule space instead of searching every time
;;(: findCurrentTTV (-> hyperon::space::DynSpace Number))
(= (findCurrentTTV $ruleSpace) (
    let* (
        ($rules (collapse (get-atoms $ruleSpace)))
        ($ttvValues (map-atom $rules $rule (extractRule TTV $rule)))
        ($_ (println! ("Current TTV values: " $ttvValues)))
    ) (max-atom $ttvValues) ;; For some reason max-atom returns a float instead of int
))

;;(: findCurrentRuleId (-> hyperon::space::DynSpace Number))
(= (findCurrentRuleId $ruleSpace) (
    let* (
        ($rules (collapse (get-atoms $ruleSpace)))
        ($ruleIds (map-atom $rules $rule (extractRule Id $rule)))
        ($_ (println! ("Current Rule IDs: " $ruleIds)))
    ) (max-atom $ruleIds)
))

(= (extractIds $rules $accum) 
   (if (== $rules ())
        $accum
        (let* (
          (($head $tail) (decons-atom $rules))
          ($id (extractRule Id $head))
          ($newAccum (union-atom $accum ($id)))
        )
          (extractIds $tail $newAccum)
        )
   ) 
)




(= (isMember $item $list) 
        (if (== $list ()) 
            False 
            (let ($head $tail) (decons-atom $list) 
                (if (== $head $item) 
                    True 
                    (isMember $item $tail)))))
(= (generateId $space)
    (let* (
      ($rules (collapse (get-atoms $space)))
      ($len (length $rules))
      ($id (random-int $len (+ $len 10)))
      ($ids (extractIds $rules ()))
    )
      (if (isMember $id $ids)
        (generateId $space)
        $id
      ) 
    )
)

(= (generateIdForList $list)
    (let* (
        ($ids (extractIds $list ()))
        ($len (length $rules))
        ($id (random-int $len (+ $len 10)))
    )
      (if (isMember $id $ids)
        (generateIdForList $list)
        $id
      )
    )
)
