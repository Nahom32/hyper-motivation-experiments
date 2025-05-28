from numpy import random
from time import sleep
from hyperon import E,S,V,MeTTa
def loop(func, atomspace):
    while True:
        wait = random.randint(2,5)
        sleep(wait)
        func(atomspace)


cache = []
curr = []
def monitor_changes(atomspace:str):
    pass
