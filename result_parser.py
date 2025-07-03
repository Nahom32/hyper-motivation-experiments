
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
    feeling_dict = {}
    while len(lexp) >= 2:
        try:
            head = lexp.pop(0)
            tail = lexp.pop(0)
            if head.startswith('('):
                head = head[1:]
            if tail.endswith(')'):
                tail = tail[:-1]
            feeling_dict[head] = float(tail)
            
        except ValueError:
            raise Exception(f"Error parsing value for key '{head}'. Current dictionary: {feeling_dict}")
        except IndexError:
            # This should ideally not happen if len(lexp) >= 2 is checked, but good for robustness
            raise Exception(f"Unexpected end of input. Current dictionary: {feeling_dict}")
            
    # After the loop, if there's any remaining element, it's an error
    if len(lexp) > 0:
        raise Exception(f"Unparsed elements remaining: {lexp}. Current dictionary: {feeling_dict}")

    return feeling_dict

if __name__ == '__main__':
    print(feeling_parser('(hateValue 0.5 happinessValue 0.4 sadnessValue 0.3 angerValue 0.2)'))

