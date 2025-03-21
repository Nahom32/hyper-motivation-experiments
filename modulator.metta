(: Modulator Type)
(: modulator (-> Symbol Number Modulator))
(: Category Type)
(: category (-> Symbol Category))
!(bind! &modulator-space (new-space))

(: insert-modulators (-> Atom empty))
(= (insert-modulators $space) (add-reduct $space (superpose (
        (modulator arousal 0.5)
        (modulator positive-valence 0.5)
        (modulator negative-valence 0.5)
        (modulator selection-threshold 0.5)
        (modulator securing-threshold 0.5)
        (modulator goal-directedness 0.5)
    
))))

!(insert-modulators &modulator-space)
!(get-atoms &modulator-space)
