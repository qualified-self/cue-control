/************************************************ //<>// //<>// //<>//
 ** Class representing a state in the HFSM
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

////////////////////////////////////////
//importing whatever we need
import java.util.*;

////////////////////////////////////////
//the state class
public class State {
  private Vector<Connection> connections;
  private Vector<Task>       tasks;
  private String             name;
  private Status             status;

  //constructor
  public State(String name) {
    this.name   = name;
    this.status = Status.INACTIVE; 
    this.tasks  = new Vector<Task>();
    this.connections = new Vector<Connection>();
  }

  //run all tasks associated to this node
  void run () {
    for (Task t : tasks) 
      t.run();

    this.status = Status.RUNNING;

    println("running all the " + tasks.size() +" tasks from state " + this.name);
  }

  //stops all tasks associated to this node
  void stop() {
    for (Task t : tasks) 
      t.stop();

    this.status = Status.INACTIVE;

    println("stopping all tasks from state " + this.name);
  }

  //it's entering a state, you need to refresh it
  void refresh() {
    for (Task t : tasks) 
      t.refresh();
  }

  //gets the current status of this state
  Status get_status() {
    return this.status;
  }

  //updates the status of this state
  void update_status () {

    //if there are no tasks, the state is done
    if (tasks.size()==0)
      this.status = Status.DONE;

    //updates the status first
    for (Task t : tasks) 
      t.update_status();

    //gets the status of the tasks associated to this state and updates accordingly
    for (Task t : tasks) {
      Status temporary_status = t.get_status();
      //updates accordingly
      if (temporary_status == Status.INACTIVE) {
        this.status = Status.INACTIVE; 
        break;
      }

      if (temporary_status == Status.RUNNING) {
        this.status = Status.RUNNING;
        //if this is a canvas
        //if (t instanceof Canvas) 

        break;
      }

      if (temporary_status == Status.DONE) 
        this.status = Status.DONE;   
    }

    //println("State " + this.name + "state was updated to " + this.status);
  }

  //function called everytime there is a new input
  State tick(Input current_input) {
    State my_return = this;

    //ticks all subcanvas that are inside this state
    if (this.status==Status.RUNNING)
      for (Task t : tasks) if (t instanceof Canvas) ((Canvas)t).tick(current_input);

    if (this.status==Status.DONE) 
      my_return = this.change_state(current_input);
    else //not ready yet...
      println("State " + this.name + " is not ready to change!");

    return my_return;
  }

  //tries to change the current state. returns the next state if it's time to change
  State change_state(Input current_input) {

    //if it' not done yet, not ready to change
    if (this.status!=Status.DONE) {
      println("State " + this.name + " is not ready to change!");
      return null;
    }

    //if done, looks for the next state
    State next_state = null;

    //iterates over array
    for (Connection c : connections) {
      //looks if c's condition corresponds to the current input. if so changes the state
      if (c.is_condition_satisfied(current_input)) {
        next_state = c.get_next_state();
        println("State was " + this.name + " . Now it is changing to " + next_state.name); 
        next_state.refresh();
        next_state.run();
        break;
      }
    }

    if (next_state==null)
      println("State " + this.name + " doesn't have a connection for this input! this can be a bug!");

    return next_state;
  }


  //add a task t to this state
  void add_task(Task t) {
    tasks.addElement(t);
    println("Task " + t.name + " added to state " + this.name);
  }

  //remove a task t from this state
  void remove_task(Task t) {
    if (tasks.contains(t))
      this.tasks.removeElement(t);
    else
      println("Unable to remove task " + t.name + " from state " + this.name);
  }

  //add a connection to this state
  void connect(Input condition, State next_state) {    

    //verifies if there is already a connection with this particular condition
    for (Connection c : connections) {
      //looks if c's condition corresponds to the current input. if so changes the state
      if (c.is_condition_satisfied(condition)) {
        println("condition " + condition + " is already used inside this state (" + this.name + ").\n    please, consider removing it or pick another condition before continuing.");
        return;
      }
    }

    //in case the condition hasnt been used, create a new connection
    Connection c = new Connection(next_state, condition);
    connections.addElement(c);
    println("Conenction created. If " + this.name + " receives " + condition + ", it goes to state " + next_state.name);
  }

  //remove a connection from this state
  void disconnect(Connection c) {
    if (connections.contains(c))
      this.connections.removeElement(c);
    else
      println("Unable to remove connection " + c.toString() + " from state " + this.name);
  }

  //@TODO function: Connect anything (all input conditions leads to a state)
  void connect_via_all_inputs (State next_state) {
    
    //get all possible inputs and converts to a vector
    Vector<Input> inputs = new Vector(Arrays.asList( (Input[])Input.values() ));

    //removing the finish
    inputs.remove(Input.FINISH);

    for (Input i : inputs) 
      this.connect(i, next_state);
      
      //this.empty_connection(next_state);
  }

  //@TODO function: Connect all remaining input  (all input conditions that were not used so far leads to a state)
  void connect_via_all_unused_inputs (State next_state) {
    //get all possible inputs and converts to a vector
    Vector<Input> inputs = new Vector(Arrays.asList( (Input[])Input.values() ));

    //removing the finish
    inputs.remove(Input.FINISH);

    //removing the conditions already used
    for (Connection c : connections)
      inputs.remove(c.condition);

    //making the remaining connections
    for (Input i : inputs) 
      this.connect(i, next_state);

    println("state " + this.name + " has the following remaining inputs: " + inputs);
  }

  //sets the finish condition
  void set_finish(State end) {
    this.connect(Input.FINISH, end);
  }
  
  
  /*//clear all current connections and adds a single empty transition to next_state
  void empty_connection(State next_state) {
    //get all possible inputs and converts to a vector
    Vector<Input> inputs = new Vector(Arrays.asList( (Input[])Input.values() ));

    //removing the finish
    inputs.remove(Input.FINISH);

    //removing the connections except the finish
    for (Connection c : connections)
      connections.remove(c);
      
    //and creates the empty transition
    this.connect(Input.EMPTY, next_state);
    
    println("state " + this.name + " has its connections deleted and a new empty trans. to state: " + next_state.name + " was added.");
  }
  */
  
  //@TODO behavior?: implement default behavior of staying in the current node?
}