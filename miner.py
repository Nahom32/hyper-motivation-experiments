
import google.generativeai as genai
from dotenv import load_dotenv
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
    import re
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
    
           """
    llm_instance = connect_llm()
    value = llm_instance.generate_content(SYSTEM_PROMPT, stream=True)
    value.resolve()
    return value.text

print(query_llm(["(perception 3 (observe Car)", "(perception 3 (head to SomeWhere))"],4))
