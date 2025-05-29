!(bind! &newSpace (new-space))
!(bind! &sngSpace (new-space))
(: data-set (-> Number Number Number))
(= (data-set $x $y) $x)

(: compareChanges (-> hyperon::space::DynSpace hyperon::space::DynSpace Atom))
(= (compareChanges $space1 $space2)
    (let* (
        ($space_val_1 (collapse (get-atoms $space1)))

        ($space_val_2 (collapse (get-atoms $space2)))
        ($net (subtraction-atom $space_val_1 $space_val_2))
    )
        (size-atom $net)
        ;; $net

    )
)


!(compareChanges &sngSpace &newSpace)
!(get-atoms &self)
!(get-type &newSpace)