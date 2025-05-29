from numpy import random
from time import sleep
from hyperon import E,S,V,MeTTa
def loop(func, pred_space, curr_space):
    while True:
        wait = random.randint(2,5)
        sleep(wait)
        func(pred_space, curr_space)


cache = []
curr = []
pred_space_val = []
def monitor_changes(pred_space_val,curr_space):

    pass
