!(bind! &newSpace (new-space))
!(bind! &sngSpace (new-space))
;; !(import! &self monitorChanges)
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

;; (: monitorChanges (-> hyperon::space::DynSpace Expression Expression))
(= (monitorChanges $space $prev)
	(let* (
		($amt (random-int 2 5))
		($_ (sleep $amt))
		($currValues (collapse (get-atoms $space)))
		($res (compareSpaceToList $space $currValues))
		($_ (println! (The result is $res)))

	)
		(monitorChanges $space $currValues)
	)
)
(= (detectChangesHelper $time $previous_times $delta $accum)
	(if (== $prev_times ())
	  	$accum
		(let* (
		       (($head $tail) (decons-atom $previous_times))
		       ($timeTv (getTruthValue $time))
		       ($latestTv (getTruthValue $head))
			($prevTvMean (stvMean $timeTv))
			($latestTvMean (stvMean $latestTv))
			($diff (- $latestTvMean $prevTvMean))

		)
		  (if (< (abs-math $diff) $delta)
		    (let $accum' (union-atom $accum (($time $head)))
		      (detectChangesHelper' $time $tail $delta $accum')
		      )	
		      (detectChangesHelper' $time $tail $delta $accum)
		  )
	  )))
;;The following function is written for checking 
;; the state of the atomspace. This is between two consecutive time cycles.
(: detectChanges (-> Expression Expression Number Expression))
(= (detectChanges $prev_times $latest_times $delta $accum)
	(if (or (== $prev_times ()) (== $latest_times ()))
		$accum
		(let* (
		       (($head $tail) (decons-atom $latest_times))
			($accum' (detectChangesHelper $head $prev_times $delta $accum))
		)
		  (detectChanges $prev_times $tail $delta $accum')
		)
		
	)
)
	

						
				

		

