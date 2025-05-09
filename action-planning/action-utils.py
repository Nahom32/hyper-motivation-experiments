import scipy.stats as st
import random
import math


def shannon_entropy(s,c,tv, prior_a: float = 1.0, prior_b: float = 1.0) -> float:
    """Return the shannon entropy of `atom`.

    The shannon entropy is calculated based on the mean of the beta
    distribution corresponding to the truth value of `atom`.

    """

    # Avoid division by zero
    
    if (math.isclose(s, 0) or math.isclose(s, 1)) and math.isclose(c, 1):
        return 0

    # Otherwise, calculate the actual Shannon entropy
    mean = tv_to_beta(tv, prior_a, prior_b).mean()
    return st.entropy([mean, 1.0 - mean], base=2)
