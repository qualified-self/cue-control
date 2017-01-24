# Cheatsheet

The mouse is only used to:
 1. click on node or decorator: select one of the nodes or decorators
 2. click on expandable triangle: toggle expansion of subtree
 3. scroll: scroll vertically in the tree

All other interactions are accomplished using the keyboard.

## File

| Key (CTRL+)   | Action | Description |
| ------------- | ------------- | ------------- |
| SPACE    | Play/pause | Toggles play/pause playback |
| R        | Reset | Resets execution process at startup and pauses playback |
| SHIFT+N  | New document | Creates a new document (will clear current document) |
| O        | Open | Opens a document |
| S        | Save  | Saves current document |
| SHIFT+S  | Save as...  | Saves current document in new file |

## Edit

These commands apply to currently selected node or decorator.

| Key (CTRL+)   | Action | Description |
| ------------- | ------------- | ------------- |
| D  | Add decorator (\*) | Adds a decorator to selected node or decorator |
| ENTER | Add sibling (\*) | Adds a new node after selected node |
| TAB  | Add child (\*) | Adds a new child to selected node (if applicable) |
| DELETE/BACKSPACE | Remove node or decorator | Removes selected node/decorator. If parent node, will also remove all children. |
| UP/DOWN | Move within | Moves selected node within its current hierarchy |
| LEFT/RIGHT | Move accross | Moves selected node accross its current hierarchy |

(\*) Switches to node/decorator creation mode. When a node or decorator is added, the user needs to input the node/decorator *type* followed by arguments (if applicable). User can interrupt node/decorator creation by pressing *DELETE*.

## Node/decorator creation

These commands apply while a node/decorator is currently created.

| Key | Action | Description |
| ----| ------------- | ------------- |
| TAB | Autocomplete  | Autocompletes node/decorator name based on currently typed string. |
| UP/DOWN | Move in drop-down | Moves in drop-down menu: name can be selected by typing ENTER. |
| ESC | Cancel creation | Cancels node/decorator creation. |
| ENTER | Create node/decorator | Creates node/decorator (if syntax is correct). |

# Node reference

## Composite nodes

### Sequence

Executes all of the node's children in order until one FAILS (FAILURE) or all SUCCEEDS (SUCCESS).

Constructors:
 * **sequence**
 * **sequence** *description(string)*

### Selector

Executes all of the node's children in order until one SUCCEEDS (SUCCESS) or all FAIL (FAILURE). Typically used in conjuction with guard decorators on children to select a task based on conditions.

If *restart* (default: false) is set to true, while the node is running it will always check again from the start in case one of its children's state would change from FAILURE to RUNNING/SUCCESS.

Constructors:
 * **selector**
 * **selector** *description(string)*
 * **selector** *restart(boolean)*
 * **selector** *description(string)* *restart(boolean)*

### Parallel

Executes all of the node's children in parallel.

Parameter *isSequencePolicy* (default: true) determines how the node reacts to the return result of its children:
 * Sequence policy (isSequencePolicy=true): FAILS as soon as any one of the node's children FAILS; if all children SUCCEED, returns SUCCESS
 * Selector policy (isSequencePolicy=false): SUCCEEDS as soon as any one of the node's children SUCCEEDS; if all children FAIL, returns FAILURE

Constructors:
 * **parallel**
 * **parallel** *description(string)*
 * **parallel** *isSequencePolicy(boolean)*
 * **parallel** *description(string)* *isSequencePolicy(boolean)*

### Simple parallel

Executes all of the node's children in parallel, with a priority on the first child. It repeats the execution of all children following the first one, until the first children either FAILS or SUCCEEDS. If any of the children FAILS, also FAILS.

This node is used to run fast parallel tasks (that usually take one step) while a main task is running.

Constructors:
 * **simple-parallel**
 * **simple-parallel** *description(string)*

## Task nodes

### Blackboard set

Sets a blackboard variable to some value or expression. If variable does not exist, creates it.

Constructors:
 * **blackboard-set** *variable-name(string)* *expression(object)*

Examples:
 * **blackboard-set** *counter* *0*
 * **blackboard-set** *counter* *"$counter+1"*

### Blackboard ramp

Ramps a blackboard variable between two values or expression over a certain period (in seconds).

Constructors:
 * **blackboard-ramp** *variable-name(string)* *to(object)* *timeout(float)*
 * **blackboard-ramp** *variable-name(string)* *from(object)* *to(object)* *timeout(float)*

### Constant

Returns a constant result (SUCCESS, FAILURE, or RUNNING).

Constructors:
 * **constant** *state(string)*

Examples:
 * **constant** SUCCESS
 * **constant** FAILURE
 * **constant** RUNNING

### Delay

Waits for a given time (in seconds) then SUCCEEDS. Timeout can be specified as an expression.

Constructors:
 * **delay** *timeout(string)*
 * **delay** *description(string)* *timeout(string)*

### OSC receive

Waits for an OSC message to arrive and sets a blackboard variable according to the received argument.

Constructors:
 * **osc-receive** *message(string)* *variable-name(string)*
 * **osc-receive** *message(string)* *variable-name(string)* *timeout(float)*

### OSC send

Sends an OSC message (optionally based on an expression).

Constructors:
 * **osc-send** *addr-pattern(string)*
 * **osc-send** *addr-pattern(string)* *expression(string)*

### Sound

Plays a sound file.

Constructors:
 * **sound** *filename(string)*

### Text

Outputs expression to the console.

Constructors:
 * **text** *expression(string)*

## Decorators

Decorators are special elements that can be added to a node or to another decorator to modify its behavior.

### Chronometer

Keeps executing child node until timeout is reached.

Constructors:
 * **chrono** *timeout(float)*

### Constant

Returns a constant result (SUCCESS, FAILURE, or RUNNING) overriding the result of its child.

Constructors:
 * **constant** *state(string)*

### Guard

Call the node if and only if guard condition checks to be true; otherwise does not execute the node and returns FAILURE (unless option *succeedOnFalse* is set to true, in which case returns SUCCESS).

Constructors:
 * **guard** *value(boolean)*
 * **guard** *expression(string)*
 * **guard** *expression(string)* *succeedOnFalse(boolean)*

## Randomize

Executes children in a random order. Can only be added as a decorator of a composite node (sequence, selector, parallel).

Constructors:
 * **randomize**

## While

Keeps executing child node while condition checks.

Constructors:
 * **while** *value(boolean)*
 * **while** *expression(string)*
