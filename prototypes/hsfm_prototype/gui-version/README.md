#Gui version
This folder will store the prototype that implements a simple UI for users.

#Manual
This manual is organized according to functionalities available for each data structure as follows:
![image](screenshot.jpg)

##State
| Action | Required interaction |
| ------------- | ------------- |
| Add new state | Move the mouse to an empty position on canvas and press the "+" key. |
| Edit state name | Click on a state, and retype its name. |
| Move state | Drag the state using the mouse.|
| Remove state | Move the mouse to a state and press the "-" key. |

##Task
| Action | Required interaction |
| ------------- | ------------- |
| Add new task | Move the mouse to a state name and press the "+" key. |
| Edit task | Click on a task. Different options are available depending on the task type. |
| Remove task | Move the mouse to a task and press the "-" key. |

##Connections
| Action | Required interaction |
| ------------- | ------------- |
| Add new connection | Hold the "shift" key and drag the initial state towards the destination state. |
| Edit connection | Click on a connection label and retype the new condition (needs to be a logical expression). |
| Change priority | Click on the number on the side of the connection label and chose the new priority. |
| Remove connection | Move the mouse to a connection label and press the "-" key. |

##UI Buttons
| Button | Description |
| ------------- | ------------- |
| Play | Executes the current state machine. |
| Stops| Stops the execution of the state machine. |
| Save | Saves the current state machine to a file. |
| Load | Loads a state machine from file. |

##Blackboard
No functionalities are available for the blackboard.
