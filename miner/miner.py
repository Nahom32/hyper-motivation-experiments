
import google.generativeai as genai
from dotenv import load_dotenv
from typing import List
import re
import os 
def connect_llm():
    """
    A simple terminal-based chatbot using Google's Gemini API.
    """
    load_dotenv()
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY not found in .env file")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('models/gemini-2.5-flash')
    return model

def validateSyntax(rule: str) -> bool:
    rule = rule.strip()
    pattern = re.compile(
        r"""
        ^\(\(:\s*\w+\s+                                   # rule ID (e.g., r7)
        \(\(TTV\s+\d+\s+\(STV\s+[0-9.]+\s+[0-9.]+\)\)\s+   # TTV and STV
        \(IMPLICATION_LINK\s+
            \(AND_LINK\s+
                \(\(Goal\s+[\w\-]+                         # Goal name (allowing _)
                \s+[0-9.]+\s+[0-9.]+\)\s+                   # Goal confidence values
                [\w\-]+\)\)\s+                             # Action name (with _ allowed)
            \(Goal\s+[\w\-]+\s+[0-9.]+\s+[0-9.]+\)         # Goal conclusion
        \)\)\)\s+[0-9.]+\)$                                # trailing number (score)
        """,
        re.VERBOSE | re.DOTALL,
    )

    # Adjusted regex to support underscores and multi-line formatting
    return bool(pattern.match(rule))

def query_llm(perceptionList, noOfRules):
    SYSTEM_PROMPT = f"""
        You are going to take a list of percetions as an agent of the form (perception $timeCycle $perceptionValue) 
        The perception list is {perceptionList} so based on the perception List generate a list of cognitive schemas that 
        Look like the following:
    
                (: <<name reference>>
                    (TTV <<cycle>>)
                    (STV <<belief>> <<confidence>>)
                    (Complexity 1)
                    (Context (<<contextInformation about the environment>>)
                    (Action <<ATTACK SWORD>>)
                    (Goal <<Goal Value>>
                )
                The belief and the confidence values are between [0,1] while the <<cycle>> is a natural number describing the timeCycle. The contextInformation
                about the environment is the an s-expression containing information about the environment. The number of rules generated should be {noOfRules} return the rules as a list of python expressions.
                Please Bro, don't write anything except the generated schemas as a python List.
    
           """
    llm_instance = connect_llm()
    value = llm_instance.generate_content(SYSTEM_PROMPT, stream=True)
    value.resolve()
    return value.text


def convert_to_list(txtChunck):
    tokens = re.findall(r'\(|\)|[^\s()]+', txtChunck)
    stack = [[]]
    for token in tokens:
        if token == '(':
            new_list = []
            stack[-1].append(new_list)
            stack.append(new_list)
        elif token == ')':
            stack.pop()
        else:
            stack[-1].append(token)
    return stack[0][0] if stack else []



def preprocess_llm_response(raw_data:str) -> List:
    import ast
    clean_output = re.sub(r"```(?:python)?|```", "", raw_data).strip()
    schemas = ast.literal_eval(clean_output)
    ##return [convert_to_list(i) for i in schemas]
    data = " "
    for i in schemas:
        data+=" "
        data+=i 
    return "(" + data + ")"
    
def pyModuleX(metta: MeTTa, name: Atom, *args: Atom):
    payload_expression: ExpressionAtom = args[0]
    actual_arg_atoms = payload_expression.get_children()
    functionName = name.get_name()
    handler_args: list[str] = [str(arg) for arg in actual_arg_atoms]

    # run
    result = globals()[functionName](*handler_args)

    return metta.parse_all(result)

def validateResponses(schemaList: List) -> List[int]:
    return [i for i in range(len(schemaList)) if validateSyntax(schemaList[i]) == False]


    
    
llm_result = query_llm(["(perception 3 (observe Car)", "(perception 3 (head to SomeWhere))"],4)
print(preprocess_llm_response(llm_result))
#print(llm_result)
#print(len(llm_result))
##print(validateResponses(llm_result))


