!(bind! &newSpace (new-space))
!(bind! &sngSpace (new-space))
(: NetDifference Type)
(: netDiff (-> Number Expression NetDifference))

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



