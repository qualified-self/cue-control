/************************************************
 ** Class representing the main canvas **********
 ************************************************
 ** jeraman.info, Oct. 3 2016 *******************
 ************************************************
 ************************************************/

public class Canvas extends Task {
  State begin, end, actual;
  Vector<State> states;
  Input input_condition;

  //contructor
  public Canvas (String name) {
    super (name);
    begin  = new State("BEGIN_" + name);
    end    = new State("END_"+name);
    states = new Vector<State>();
    actual = begin;

    println("Canvas " + this.name + " is inited!");
  }

  //run all tasks associated to this node
  void run () {
    this.status = Status.RUNNING;
    actual.run();
    println("running the canvas " + this.name);
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

    println("stopping canvas" + this.name);
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
      println("Canvas " + this.name +  " has reached its end and has successfully executed!");
    }

    //if there are no states associated to this canvas
    if (states.size()==0 & begin.connections.size()==0) {
      this.status = Status.DONE;
      println("Canvas " + this.name +  " is empty! Done!");
    }
    
    //checks if currect actual has any empty transition
    //check_for_empty_transition();
  }

  //function called by canvas at every update looking for empty connections
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

  //add a state s to this canvas
  void add_state(State s) {
    states.addElement(s);
    println("State " + s.name + " added to canvas " + this.name);
  }

  //remove a state s from this canvas
  void remove_state(State s) {
    if (states.contains(s))
      this.states.removeElement(s);
    else
      println("Unable to remove state " + s.name + " from canvas " + this.name);
  }

  //add a task t to the initialization of this canvas
  void add_initialization_task (Task t) {
    begin.add_task(t);
    println("Task " + t.name + " added to the initialization of canvas " + this.name);
  }

  //remove a task t to the initialization of this canvas
  void remove_initialization_task (Task t) {
    begin.remove_task(t);
    println("Task " + t.name + " removed from the initialization of canvas " + this.name);
  }

  //add a task t to the initialization of this canvas
  void add_finalization_task (Task t) {
    end.add_task(t);
    println("Task " + t.name + " added to the finalization of canvas " + this.name);
  }

  //remove a task t to the initialization of this canvas
  void remove_finalization_task (Task t) {
    end.remove_task(t);
    println("Task " + t.name + " removed from the finalization of canvas " + this.name);
  }

  void all_states_connect_to_finish_when_finished() {
    begin.connect(Input.FINISH, this.end);    

    for (State s : states) 
      s.connect(Input.FINISH, this.end);
  }
}