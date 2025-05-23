from hyperon import MeTTa,E,S,V
from numpy import random

metta = MeTTa()

# metta.run('''
#     (data w x)
#     (data a b)
#     (w d x)
#     !(collapse (match &self (data $x $y) ($x $y)))
# ''')
# pattern = '$x'
# #print(result.pop())
# print(metta.space().query(f'{pattern}'))
query_var = metta.parse_all('$x').pop()
for i in range(10):
    rnd_num = random.rand()
    atom = metta.parse_single(f'{rnd_num}')
    
    metta.space().add_atom(atom)
query_result = metta.space().query(query_var)
print(query_result)
print(type(query_result))


    

