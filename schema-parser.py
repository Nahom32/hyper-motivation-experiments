from typing import List, Any, Dict
import re
def convertSExpression(exp: str) -> Dict[str,Any]:
    '''
        Args
        =======================================
        exp: a string containing an s-expression in the following format
        (C&A->G) This is wrapped with a truth value. The value is a second 
        order distribution.
        (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) 

    '''
    order = ['handle','TruthValue','context', 'action','goal']
    exp_sep = exp.split(' ')
    exp_sep = list(filter(lambda x: x != " ", exp_sep))
    holder = dict()
    prev = ''
    unparsed_vals = {'(', ')', '(:', ':', '((', '))'}
    pattern = re.compile(
        r"^\(: \s*(\S+)"  # Group 1: $handle (at the start of the string)
        r"\s+\("          # Matches the opening parenthesis of the main content block
        r"\s+\(TTV \s*(\S+) \s+\(STV \s*(\S+) \s*(\S+)\)\)" # Group 2: $time, Group 3: $bel, Group 4: $conf (for TTV)
        r"\s+\(IMPLICATION_LINK \s+\(AND_LINK \s*\(([^ ]+) \s*([^)]+)\)\)\s*(\S+)\)" # Group 5: $context, Group 6: $action, Group 7: $goal
        r"\)\)$"          # Matches the closing parentheses of the main content block and the outer S-expression (at the end of the string)
    )

    match = pattern.match(s_expression_string)

    if match:
        # Extract the captured groups
        handle = match.group(1)
        ttv_time = match.group(2)
        stv_bel = match.group(3)
        stv_conf = match.group(4)
        and_link_context = match.group(5)
        and_link_action = match.group(6)
        goal = match.group(7)

        # Organize the extracted data into a structured dictionary
        parsed_data = {
            "handle": handle,
            "ttv_values": {
                "time": ttv_time,
                "stv_values": {
                    "belief": stv_bel,
                    "confidence": stv_conf
                }
            },
            "implication_link": {
                "and_link_values": {
                    "context": and_link_context,
                    "action": and_link_action
                },
                "goal": goal
            }
        }
        return parsed_data

    else:
        return {}

        
        


