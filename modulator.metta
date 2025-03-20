(: Modulator Type)
(: modulator (-> Symbol Number Modulator))
!(bind! &modulator-space (new-space))

(= (insert-modulators $space) (add-reduct $space (superpose (
    (modulator Valence 0.5)
    (modulator Resolution-level 0.5)
    (modulator Securing-threshold 0.5)
    (modulator Activation-threshold 0.5)
    
    
))))

!(insert-modulators &modulator-space)
!(get-atoms &modulator-space)
