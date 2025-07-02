
from typing import Dict,Any


def feeling_parser(sexp: str) -> Dict[str,Any]:
    '''
        Description
        ============================================
        This function takes an s-expression having feeling values and parses it
        to a dictionary of the feeling states with there corresponding values
        ===========================================
    '''
    lexp = sexp.split()
    print(lexp)
    feeling_dict = {}
    for i in lexp:
        if i in ('(',')'):
            continue
        try:
            head = lexp.pop(0)
            if head.startswith('('):
                head = head[1:]
            tail = lexp.pop(0)
            if head.endswith(')'):
                tail = tail[:-1]
            feeling_dict[head] = float(tail)
        except:
            raise Exception(f'{feeling_dict}')
    return feeling_dict
print(feeling_parser('(hateValue 0.5 happinessValue 0.4 sadnessValue 0.3 angerValue 0.2)'))
