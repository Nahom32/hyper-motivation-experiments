!(bind! &kb (new-space))
!(bind! &child-space (new-space))

;; This function removes all occurences of an existing pattern
(= (add-atoms $space $values)
	(add-reduct $space (superpose $values)))
(= (remove-occurrences $space $pattern)
   	(let $atoms (collapse (match $space $pattern $pattern))
	  	(remove-atoms $space $atoms)))
(= (update-atoms $pattern $updater $updated)
   	(let* (
	       ($updater-atoms (collapse (get-atoms $updater)))
	       ($_ (remove-occurrences $updated $pattern))
		($_ (collapse (add-atoms $space $updated)))
	       )
	  	
	  )
)

