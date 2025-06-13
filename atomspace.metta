!(bind! &kb (new-space))
!(bind! &child-space (new-space))

;; This function removes all occurences of an existing pattern
(= (remove-occurences $space $pattern)
   	(let $atoms (collapse (match $space $pattern $pattern))
	  	(remove-atoms $space $atoms)))
(= (update-atoms $updated $updater)
   	(let* (
	       ($updater-atoms (collapse (get-atoms $updater)))
	       )))

