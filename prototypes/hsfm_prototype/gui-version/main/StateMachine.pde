/************************************************
 ** Class representing the main State_Machine **********
 ************************************************
 ** jeraman.info, Oct. 3 2016 *******************
 ************************************************
 ************************************************/

public class StateMachine extends Task {
  State begin, end, actual;
  Vector<State> states;

  float stateTimerMilestone = 0;
  float stateTimer          = 0;

  //Input input_condition;
  //State_Machine_Preview preview;

  //contructor
  public StateMachine (PApplet p, String name) {
    super (p, name);
    begin   = new State("BEGIN_" + name);
    end     = new State("END_"+name);
    states  = new Vector<State>();
    //preview = new State_Machine_Preview(this);

    actual = begin;

    //sets the global variables related to this blackboard
    init_global_variables();

    if (debug)  println("State_Machine " + this.name + " is inited!");
  }

  //so far not using this method
  StateMachine clone() {
    return null;
  }

  //run all tasks associated to this node
  void run () {
    this.status = Status.RUNNING;

    update_actual(begin);

    reset_state_timer();
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
    //actual = begin;
    //update_actual(begin);
    update_actual(null);

    //resets the stateTimer for this state machine
    reset_state_timer();

    this.status = Status.INACTIVE;

    if (debug)
      println("stopping State_Machine" + this.name);
  }

  //stops all tasks associated to this node
  void interrupt() {
    //stopping all states...
    for (State s : states)
      s.interrupt();

    //stop begin and end
    begin.interrupt();
    end.interrupt();

    //updating the actual
    //actual = begin;
    //update_actual(begin);
    update_actual(null);

    //resets the stateTimer for this state machine
    reset_state_timer();

    this.status = Status.DONE;
    if (debug)  println("iterrupting State_Machine" + this.name);
  }


  void update_actual (State next) {
    actual.is_actual = false;

    //does nothing if the actuall will be null
    if (next==null) return;

    //updating the actual
    actual = next;

    actual.is_actual = true;
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
      if (debug)  println("State_Machine " + this.name +  " has reached its end and has successfully executed!");
    }

    //if there are no states associated to this State_Machine
    if (states.size()==0 & begin.connections.size()==0) {
      this.status = Status.DONE;
      if (debug)  println("State_Machine " + this.name +  " is empty! Done!");
    }

    //checks if currect actual has any empty transition
    //check_for_empty_transition();
  }

  void hide() {
    begin.hide_gui();
    for (State s : states)
      s.hide_gui();
    end.hide_gui();
  }

  void show() {
    begin.show_gui();
    for (State s : states)
      s.show_gui();
    end.show_gui();
  }

  //draws all states associated with this state_machine
  void draw() {
    //cleaning the background
    background(0);

    //drawing the entry state
    begin.draw();
    begin.draw_begin();
    //drawing the states begining to this state machine
    for (State s : states)
      s.draw();
    //drawing the end state
    end.draw();
    end.draw_end();

    //drawing the actual, if running
    if (this.status==Status.RUNNING)
      actual.draw_actual();
  }

  //function called by State_Machine at every update looking for empty connections
  //void check_for_empty_transition () {
  //  tick(Input.EMPTY);
  //}

  //function called everytime there is a new input
  void tick() {

    //if not ready yet, returns...
    if (this.status==Status.INACTIVE || this.status==Status.DONE) {
      reset_state_timer(); //sets timer to zero
      return;
    }

    //stores the results for the state changing
    State next = null;

    //updates global variables in the blackboard
    update_global_variables();

    //updates the status of the hfsm
    update_status();

    //tries to update the next
    next = actual.tick();

    //if it really changed to another state
    if (next!=null && next!=actual) {
      //refreshing the stateTimer in the blackboard
      reset_state_timer();
      if (debug) println("changing to a different state. reset stateTimer.");

    } else {
      if (debug) println("changing to the same state. do not reset stateTimer.");
    }

    //in case next is not null, change state!
    if (next!=null)
      update_actual(next);

  }

  //add a state s to this State_Machine
  void add_state(State s) {
    //check if there is already a state with the same name
    State result = get_state_by_name(s.name);

    //in case there isn't
    if (result==null) {
      states.addElement(s);
      println("State " + s.name + " added to State_Machine " + this.name);
    } else {
      println("There is alrealdy a state with this same name. Please, pick another name!");
    }
  }

  //remove a state s from this State_Machine
  void remove_state(State s) {
    if (states.contains(s)) {
      //remove the state fmor the list
      this.states.removeElement(s);
      //remove all tasks associated with the deleted state
      s.remove_all_tasks();
      //removes its ui components
      cp5.remove(s.name);
    } else
      println("Unable to remove state " + s.name + " from State_Machine " + this.name);
  }

  //removes a state based on a certain x y position in the screen
  void remove_state(int x, int y) {
    //iterates over all states
    for (State s : states)
      //if it intersects with a certain x y position
      if (s.intersects_gui(x, y)) {
        //removes this state
        this.remove_state(s);
        //and breaks (one remotion per time))
        return;
      }
  }

  //returns a state by its name. returns null if not available
  State get_state_by_name(String name) {
      State result = null;

      if (this.begin.name.equalsIgnoreCase(name)) result=this.begin;
      if (this.end.name.equalsIgnoreCase(name))   result=this.end;

      //iterates over all states
      for (State s : states)
        if (s.name.equalsIgnoreCase(name)) result=s;

      if (result!=null)
        println("found! " + result.toString());
      else
        println("problem!");

      //returns the proper result
      return result;
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

  //inits the global variables related to this blackboard
  void init_global_variables() {
    bb.put(this.name+"_stateTimer", 0);
  }

  //updates the global variable related to this blackboard
  void update_global_variables() {
    update_state_timer();
    bb.replace(this.name+"_stateTimer", this.stateTimer);
    //println("update variable " + this.stateTimer);
  }

  //updates the stateTimer variable related to this state machine
  void update_state_timer() {
      this.stateTimer = ((float)millis()/1000)-stateTimerMilestone;
  }

  //resets the stateTimer variable related to this state machine
  void reset_state_timer() {
      this.stateTimerMilestone = (float)millis()/1000;
      this.stateTimer          = 0;
      update_global_variables();
  }

  //returns how many states we have in this state machine
  int get_states_size() {
    return this.states.size();
  }

  //returns a state that intersect test_x, test_y positions
  State intersects_gui(int test_x, int test_y) {
    State result = null;

    //println("testing intersection... " + test_x + " " + test_y);

    //testing the begin & end states
    if (this.begin.intersects_gui(test_x, test_y))  return this.begin;
    if (this.end.intersects_gui(test_x, test_y))    return this.end;

    //iterates over the remaining states
    for (State s : states)
      //if intersects...
      if (s.intersects_gui(test_x, test_y)) {
        println("i found someone to be intersected");
        //updates the result
        result = s;
        break;
      }

    return result;
  }

  //reinit any name the user was trying to change it
  void reset_all_names_gui() {
    //resets the begin and the end states
    this.begin.init_state_name_gui();
    this.end.init_state_name_gui();
    
    //iterates over the remaining states
    for (State s : states)
      //reinit the name in case the user was trying to change it
      s.init_state_name_gui();
  }
}
