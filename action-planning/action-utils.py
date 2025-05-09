import scipy.stats as st
import random
import math


def shannon_entropy(s,c,count,mean, prior_a: float = 1.0, prior_b: float = 1.0) -> float:
    """Return the shannon entropy of `atom`.

    The shannon entropy is calculated based on the mean of the beta
    distribution corresponding to the truth value of `atom`.

    """

    # Avoid division by zero
    
    if (math.isclose(s, 0) or math.isclose(s, 1)) and math.isclose(c, 1):
        return 0

    # Otherwise, calculate the actual Shannon entropy
    mean = tv_to_beta(count,mean, prior_a, prior_b).mean()
    return st.entropy([mean, 1.0 - mean], base=2)

def tv_to_beta(
    count,mean, prior_a: float = 1.0, prior_b: float = 1.0
) -> st.rv_continuous:
    """Convert a truth value to a beta distribution.

    Given a truth value, return the beta distribution that best fits
    it.  Two optional parameters are provided to set the prior of the
    beta-distribution, the default values are prior_a=1 and prior_b=1
    corresponding to the Bayesian prior.

    """

   
    pos_count = count * mean  # the mean is actually the mode
    a = prior_a + pos_count
    b = prior_b + count - pos_count
    return st.beta(a, b)

