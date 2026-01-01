
(= (extractIds $space) (collapse (extractRule Id (get-atoms $space))))
(= (generateId $space)
    (let* (
      ($rules (collapse (get-atoms $space)))
      ($len (length $rules))
      ($id (random-int $len (+ $len 10)))
      ($ids (extractIds $space))
    )
      (if (isMember $id $ids))
        (generateId $space)
        $id
    
    )
)
