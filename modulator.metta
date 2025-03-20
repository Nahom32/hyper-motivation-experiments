(: Modulator Type)
(: modulator (-> Symbol Number Modulator))
(: Category Type)
(: category (-> Symbol Category))
!(bind! &modulator-space (new-space))

(: insert-modulators (-> Atom empty))
(= (insert-modulators $space) (add-reduct $space (superpose (
    (modulator Valence 0.5)
    (modulator Resolution-level 0.5)
    (modulator Securing-threshold 0.5)
    (modulator Activation-threshold 0.5)
    
    
))))

!(insert-modulators &modulator-space)
!(get-atoms &modulator-space)
