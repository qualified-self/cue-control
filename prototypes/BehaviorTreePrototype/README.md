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
| UP/DOWN | Move within | Moves selected node within its current hierarchy |
| LEFT/RIGHT | Move accross | Moves selected node accross its current hierarchy |

(\*) Switches to node/decorator creation mode. When a node or decorator is added, the user needs to input the node/decorator *type* followed by arguments (if applicable). User can interrupt node/decorator creation by pressing *DELETE*.

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

## Task nodes

## Decorators
