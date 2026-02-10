(= (unify $a $b $then $else)
   (if (= $a $b)
       (eval $then)
       (eval $else)))
       
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

; (: extractRuleId (-> Expression Number))
(= (extractRuleId $rule) (
    unify (: Rule $id $ttv $stv $complexity $implication) $rule
        $id
        -1
))

; (: extractRuleTTV (-> Expression Number))
(= (extractRuleTTV $rule) (
    unify (: Rule $id (TTV $ttv) $stv $complexity $implication) $rule
        $ttv
        -1
))

(= (extractRuleContext $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION (AND (Context $context-stv (AND $context)) $action) $goal))
      $rule
      $context
      empty         
))

(= (extractRuleContextValues $rule) (
    let $contexts (extractRuleContext $rule) (map-atom $contexts $context ((index-atom $context 0) (index-atom $context 1)))
))

(= (extractRuleAction $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION (AND $context (Action (SEQ_AND $action))) $goal)) $rule
        $action
        empty
))

(= (extractRuleGoal $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION $and-link (Goal $goal-stv (AND $goal)))) $rule
        $goal
        empty
))

(= (extractRuleGoalValues $rule) (
    let $goals (extractRuleGoal $rule) (map-atom $goals $goal ((index-atom $goal 0) (index-atom $goal 1)))
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

(= (extractAllContext $rule) (
    unify (: Rule $id $ttv $stv $complexity (IMPLICATION (AND $context $action) $goal)) $rule
        $context
        empty
))



(= (calculateComplexity $rule) (
    let* (
        ($action (extractRuleAction $rule))
        ($actionCount (size-atom $action))
    ) $actionCount
))

;; Filters rules from a rule space based on matching action values
(= (filterByAction $action $ruleSpace) (
    let* (
        ($rules (collapse (get-atoms $ruleSpace)))
        ($filtered (filter-rules-by-action $action $rules))
    ) $filtered
))

(= (filter-rules-by-action $action $rules) (
    if (== () $rules)
        ()
        (let* (
            (($head $tail) (decons-atom $rules))
            ($ruleAction (eval (extractRule Action $head)))
            ($isMatch (eval (areSimilar $action $ruleAction)))
            ($restMatches (eval (filter-rules-by-action $action $tail)))
        ) (if $isMatch
            (cons-atom $head $restMatches)
            $restMatches))
))

;; Filters rules from a rule space based on matching goal values
(= (filterByGoal $goal $ruleSpace) (
    let* (
        ($rules (collapse (get-atoms $ruleSpace)))
        ($filtered (filter-rules-by-goal $goal $rules))
    ) $filtered
))

(= (filter-rules-by-goal $goal $rules) (
    if (== () $rules)
        ()
        (let* (
            (($head $tail) (decons-atom $rules))
            ($ruleGoal (eval (extractRule GoalValues $head)))
            ($isMatch (eval (areSimilar $goal $ruleGoal)))
            ($restMatches (eval (filter-rules-by-goal $goal $tail)))
        ) (if $isMatch
            (cons-atom $head $restMatches)
            $restMatches))
))

;; Filters rules from a rule space based on matching context values
(= (filterByContext $context $ruleSpace) (
    let* (
        ($rules (collapse (get-atoms $ruleSpace)))
        ($filtered (filter-rules-by-context $context $rules))
    ) $filtered
))

(= (filter-rules-by-context $context $rules) (
    if (== () $rules)
        ()
        (let* (
            (($head $tail) (decons-atom $rules))
            ($ruleContext (eval (extractRule ContextValues $head)))
            ($isMatch (eval (areSimilar $context $ruleContext)))
            ; ($_ (println! ("Context match: " $isMatch $context " vs " $ruleContext)))
            ($restMatches (filter-rules-by-context $context $tail))
        ) (if $isMatch
            (cons-atom $head $restMatches)
            $restMatches))
))

(= (filter-rules-by-antecedent $antecedent $rules) (
    if (== () $rules)
        ()
        (let* (
            (($head $tail) (decons-atom $rules))
            ($ruleAntecedent (eval (extractRule ContextAndAction $head)))
            ($isMatch (eval (areSimilar $antecedent $ruleAntecedent)))
            ($restMatches (eval (filter-rules-by-antecedent $antecedent $tail)))
        ) (if $isMatch
            (cons-atom $head $restMatches)
            $restMatches))
))
