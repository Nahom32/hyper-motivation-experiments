!(bind! &newSpace (new-space))
!(bind! &sngSpace (new-space))
(: NetDifference Type)
(: netDiff (-> Number Expression NetDifference))
!(get-type (netDiff 7 (a b c))) 
(: compareChanges (-> hyperon::space::DynSpace hyperon::space::DynSpace Expression))
(= (compareChanges $space1 $space2)
    (let* (
        ($space_val_1 (collapse (get-atoms $space1)))

        ($space_val_2 (collapse (get-atoms $space2)))
        ($net (subtraction-atom $space_val_1 $space_val_2))
    )
        ((size-atom $net) $net)
        

    )
)

(: compareSpaceToList (-> hyperon::space::DynSpace Expression Expression))
(= (compareSpaceToList $space $list)
	(let* (
		($space_val (collapse (get-atoms $space)))
		($net (subtraction-atom $space_val $list))
		)
		((size-atom $net) $net)))
;; One option here could be to wrap the timer function
;; But do the logic using the meTTa language. 

(: monitorChanges (-> hyperon::space::DynSpace Expression Expression))
(= (monitorChanges $space $prev)
	(let* (
		($amt (random-int 2 5))
		($_ (timer $amt))
		($currValues (collapse (get-atoms $space)))
		($res (compareSpaceToList $space $currValues))

	)
		(monitorChanges $space $currValues)
	)
)


