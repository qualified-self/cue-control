/************************************************
 ** Class representing the main State_Machine **********
 ************************************************
 ** jeraman.info, Oct. 3 2016 *******************
 ************************************************
 ************************************************/

public class State_Machine extends Task {
  State begin, end, actual;
  Vector<State> states;
  Input input_condition;

  //contructor
  public State_Machine (String name) {
    super (name);
    begin  = new State("BEGIN_" + name);
    end    = new State("END_"+name);
    states = new Vector<State>();
    actual = begin;

    println("State_Machine " + this.name + " is inited!");
  }

  //run all tasks associated to this node
  void run () {
    this.status = Status.RUNNING;
    actual.run();
    println("running the State_Machine " + this.name);
  }

  //stops all tasks associated to this node
  void stop() {
    //stopping all states...
    for (State s : states) 
      s.stop();

    //stop begin and end
    begin.stop();
    end.stop();

    //updating the actual
    actual = begin;

    this.status = Status.INACTIVE;

    println("stopping State_Machine" + this.name);
  }

  //updates the status of this state
  void update_status() {

    //if it' done, no point to execute this
    if (this.status == Status.DONE)  return;

    //updating the status of the actual
    actual.update_status();
    
    //if this state finished. test this condition, maybe you need to overload the comparison!
    if (actual==end) {
      this.status = Status.DONE;
      println("State_Machine " + this.name +  " has reached its end and has successfully executed!");
    }

    //if there are no states associated to this State_Machine
    if (states.size()==0 & begin.connections.size()==0) {
      this.status = Status.DONE;
      println("State_Machine " + this.name +  " is empty! Done!");
    }
    
    //checks if currect actual has any empty transition
    //check_for_empty_transition();
  }

  //function called by State_Machine at every update looking for empty connections
  //void check_for_empty_transition () {
  //  tick(Input.EMPTY);
  //}

  //function called everytime there is a new input
  void tick(Input current_input) {
    //updates input condition
    this.input_condition = current_input;

    //tries to update the next
    State next = null;

    //if it' a finish command, go to the last state. otherwise, continue the execution
    //if (current_input==Input.FINISH) {
    //  actual = end;
    //  actual.refresh();
    //  actual.run();
    //}

    next = actual.tick(input_condition);

    if (next!=null) //in case next is not null, change state!
      actual = next;
  }

  //add a state s to this State_Machine
  void add_state(State s) {
    states.addElement(s);
    println("State " + s.name + " added to State_Machine " + this.name);
  }

  //remove a state s from this State_Machine
  void remove_state(State s) {
    if (states.contains(s))
      this.states.removeElement(s);
    else
      println("Unable to remove state " + s.name + " from State_Machine " + this.name);
  }

  //add a task t to the initialization of this State_Machine
  void add_initialization_task (Task t) {
    begin.add_task(t);
    println("Task " + t.name + " added to the initialization of State_Machine " + this.name);
  }

  //remove a task t to the initialization of this State_Machine
  void remove_initialization_task (Task t) {
    begin.remove_task(t);
    println("Task " + t.name + " removed from the initialization of State_Machine " + this.name);
  }

  //add a task t to the initialization of this State_Machine
  void add_finalization_task (Task t) {
    end.add_task(t);
    println("Task " + t.name + " added to the finalization of State_Machine " + this.name);
  }

  //remove a task t to the initialization of this State_Machine
  void remove_finalization_task (Task t) {
    end.remove_task(t);
    println("Task " + t.name + " removed from the finalization of State_Machine " + this.name);
  }

  void all_states_connect_to_finish_when_finished() {
    begin.connect(Input.FINISH, this.end);    

    for (State s : states) 
      s.connect(Input.FINISH, this.end);
  }
}