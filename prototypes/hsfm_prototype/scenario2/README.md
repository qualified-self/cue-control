#Scenario 2
This second scenario continues exploring the [Hierarchical Finite State Machines (HFSM)](https://en.wikipedia.org/wiki/UML_state_machine#Hierarchically_nested_states) as defined in [Scenario 1](../scenario1/README.md).

However, the goal here was to investigate to what investigate physical and integrated aspects of the HSFM when controlling an multimedia environment.

#Technical Setup
##Input sensors
BITalino sensors.
##Multimedia output
Composed of:
- Haptics: two integrated Aura devices;
- Sound: Two compositions: a regular heartbeat sample and a custom composition).
- Light: One DMX-based strobe;
##Multimedia server
A Macbook pro connected to the same wireless network. All multimedia output are connected to this server.
##The HFSM cue control
Is running on a second macbook computer, which is also connected to the same network.

#The scenario
This new scenario was written by Sofian. It is presented [here](https://github.com/qualified-self/documents/blob/master/cue-trigger-system/Scenarios.md). My corresponding HFSM structure is implemented as follows:
![image](hfsm-scenario-2.jpg)
