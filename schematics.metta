!(bind! &kb (new-space))
(: schema Type)
(: operator Type)
(: scon (-> $context $action $time $goal schema))

(=(get-schemas-with-time-cycle $kb $time-cycle)
    (collapse (match $kb (scon $context $action $time-cycle $goal)))
)