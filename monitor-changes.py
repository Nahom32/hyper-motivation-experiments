from numpy import random
from time import sleep
def monitor_changes(func, atomspace):
    while True:
        wait = random.randint(2,5)
        sleep(wait)
        func(atomspace)
