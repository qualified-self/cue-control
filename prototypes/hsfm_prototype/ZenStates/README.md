#About
This repository stores a new version of the HFSMPrototype—temporarily named *ZenStates*. It should support:
0. Code migrated to eclipse IDE;
1. Hierarchical state machines;
2. Reuse of existing patches;
3. Scripting (Super collider? Java script?);
4. Shortcuts (in order to better suit advanced users).

ZenStates can be described in terms of three principles:

##Reification
Because the software is based on a set of abstract concepts (e.g. state, task, connection) that are represented by objects inside the software. These objects have a visual representation that are at core of the interaction.

##Polymorphism
Because most of the commands (i.e. instrument, as defined by [1]) can be applied to different objects. For example, the same "creation" tool (represented by the '+' key) can be applied to either a state, a task, or a connection. Other instruments implemented so far are "removing", and "editing". Future instruments might include: redo, undo, cut, and copy.

##Reuse
Because it should be possible to users to reuse material previously created. For example it should be possible to reuse: a) previously saved state machines (as a external abstraction in Puredata or Max/MSP);  b) previously defined variables, by providing autocomplete functionality.


[1] Beaudouin-Lafon, M. & Mackay, W. (2000). Reification, Polymorphism and Reuse: Three Principles for Designing Visual Interfaces. Proc. Advanced Visual Interfaces, AVI 2000, Palermo (Italie), ACM Press, pp 102-109.
