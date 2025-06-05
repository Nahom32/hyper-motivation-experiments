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

(= (getTV (constructor (stv $x $y))) (stv $x $y))
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


(= (cogTvMean (stv $x $y)) (/ (+ $x $y) 2))
(: detectChangesHelper (-> Expression Expression Number Expression Expression))
(= (detectChangesHelper $time $previous_times $delta $accum)
	(if (== $previous_times ())
	  	$accum
		(let* (
		       (($head $tail) (decons-atom $previous_times))
		       ($timeTv (getTV $time))
		       ($latestTv (getTV $head))
			($prevTvMean (cogTvMean $timeTv))
			($latestTvMean (cogTvMean $latestTv))
			($diff (- $latestTvMean $prevTvMean))

		)
		  (if (< (abs-math $diff) $delta)
		    (let $accum' (union-atom $accum (($time $head)))
		      (detectChangesHelper $time $tail $delta $accum')
		      )	
		      (detectChangesHelper' $time $tail $delta $accum)
		  )
	  )))
;;The following function is written for checking 
;; the state of the atomspace. This is between two consecutive time cycles.
(: detectChanges (-> Expression Expression Number Expression Expression))
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
(: flipTruthValue (-> hyperon::space::DynSpace Expression Expression))
(= (flipTruthValue &space $atom)
   	(let* (
		($_ (remove-atom $space $atom))
		($newAtom (changeTruthValue $atom (stv 1 1)))

	)
	  	(add-atom $space $newAtom)
	  )
)
!(detectChangesHelper (constructor (stv 0.3 0.5)) ((constructor (stv 0.3 0.5)) (constructor (stv 0.4 0.6))) 0.5 ()) 

						
				
		
!(detectChanges ((constructor (stv 0.1 0.1)) (constructor (stv 0.2 0.3)) (constructor (stv 0.3 0.5))) ((constructor (stv 0.3 0.5)) (constructor (stv 0.4 0.6))) 0.5 ()) 
