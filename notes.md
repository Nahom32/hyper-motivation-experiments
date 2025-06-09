# Notes on Integration of OpenPsi
How are going to compose the separate atomspace used in our implementations. 

Since the design of the OpenPsi was intended to use one atomspace while the mind agents update that. We are implementing different atomspaces for one case. Should we implement a hierarchy of atomspaces where each mind agent has its own and grand database holding the atom. 
Shoud we implement a controller in another programming language to parallelize them?
How are we going to integrate a learning component for OpenPsi. Is the thompson sampling based action selection enough to simulate learning? This is because there is experiential change the goal values and the modulator values which the feeling component changes as the result of the previous changes. But inorder to fulfill learning as a black box model there must be a performance increase in taking better decisions given an identical state. Let us say an agent $A$ has a configuration $C$, then learning can happen if an experience $E$ on an agent $A$ changes the configuration $C \longrightarrow C'$. But due to $C'$ the performance of $A$ should increase by some metric $M$. 


OpenPsi in this scenario doesn't have that even if it is an integrated agent. So inorder for this agent to learn reinforcement learning techniques should be incorporated to openpsi or goal stability learning should take place in OpenPsi.

## How should we represent context within OpenPsi
This is a major question because there are confusing representations for it. The opencog wiki schematics represents the context within the schematics as a chain of goals and subgoals. But should it contain additional information about its environment. If we include information about the environment. We need to track the relationship between the goal and the environment. Is it deterministic? What is the relationship between the goal and the environment?

The context should contain the following: 
* The state of the agent within the environment.
* The previous goal
```scheme
	(: Context Type)
	(: context (-> Expression Goal Context))
```
