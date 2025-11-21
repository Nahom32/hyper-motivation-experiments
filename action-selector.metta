;;Implement a greedy action selector and executor
;;This is going to be compared with the thompson sampling implementation
(: TruthValue Type)
(: STV (-> Number Number TruthValue))
(: selectAndExecute (-> Expression Atom Expression))
(= (selectAndExecute $currRule $space $comparatorFunc)
  (let* (
    ($possibleInstances (selectInstancesViable $currRule $space))
    ($nextRule (if (>= (size-atom $possibleInstances) 1) (selectBestRule (car-atom $possibleInstances) (cdr-atom $possibleInstances) $comparatorFunc)())
    ($action (extractAction $nextRule))
  )
    (apply $action)
  ) 
)




(= (cogTvMean (STV $a $b)) (/ (+ $a $b) 2))

(= (selectBestRule  $currRule $rules $comparatorFunc)
    (if (== $rules ()) 
    $currRule  
      (let* (
          (($head $tail) (decons-atom $rules))
          ($currValue ($comparatorFunc $currRule))
          ($headValue ($comparatorFunc $head))

      )
        (if (< $currValue $headValue) (selectBestRule $head $tail $comparatorFunc) (selectBestRule $currRule $tail $comparatorFunc))
      )
      )
)
!(cogTvMean (STV 0.3 0.4))
