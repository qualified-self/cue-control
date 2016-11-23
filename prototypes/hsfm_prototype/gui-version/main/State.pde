/************************************************
 ** Class representing a state in the HFSM
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

////////////////////////////////////////
//importing whatever we need
import java.util.*;

boolean is_dragging_someone = false;

////////////////////////////////////////
//the state class
public class State {
  private Vector<Connection> connections;
  private Vector<Task>       tasks;
  private String             name;
  private Status             status;

  public boolean             is_actual;

  //variables used for the gui
  public int x;
  public int y;
  private final int size = 50;
  //accordion that stores the tasks
  private Accordion accordion;
  //private Textlabel label;
  private Textfield label;

  //constructor
  public State(String name) {
    this.name   = name.toUpperCase();
    this.status = Status.INACTIVE;
    this.tasks  = new Vector<Task>();
    this.connections = new Vector<Connection>();
    this.x = (int)random(10, 1024);
    this.y = (int)random(10, 768);

    init_gui();
    hide_gui();

    this.is_actual = false;
  }

  //constructor
  public State(String name, int x, int y) {
    this(name);
    this.x = x;
    this.y = y;

  }

  String get_name() {
    return this.name;
  }

  //run all tasks associated to this node
  void run () {
    for (Task t : tasks)
      t.run();

    this.status = Status.RUNNING;

    if(debug)
      println("running all the " + tasks.size() +" tasks from state " + this.name);
  }

  //stops all tasks associated to this node
  void stop() {
    for (Task t : tasks)
      t.stop();

    this.status = Status.INACTIVE;

    if(debug)
      println("stopping all tasks from state " + this.name);
  }

  //stops all tasks associated to this node
  void interrupt() {
    for (Task t : tasks)
      t.interrupt();

    this.status = Status.DONE;

    if(debug)
      println("interrupting all tasks from state " + this.name);
  }

  //if it's entering a state, you need to refresh it
  void refresh() {
    for (Task t : tasks)
        t.refresh();
  }

  //only refreshes and reruns completed tasks
  void refresh_and_run_completed_tasks() {
    for (Task t : tasks)
      if (t.get_status () == Status.DONE || t.get_status () == Status.INACTIVE) {
        t.refresh();
        t.run();
      }
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
        //if this is a State_Machine
        //if (t instanceof State_Machine)

        break;
      }

      if (temporary_status == Status.DONE)
        this.status = Status.DONE;
    }

    //println("State " + this.name + "state was updated to " + this.status);
  }

  //function called everytime there is a new input
  State tick() {
    State my_return = this;

    //ticks all subState_Machine that are inside this state
    if (this.status==Status.RUNNING)
      for (Task t : tasks) if (t instanceof StateMachine) ((StateMachine)t).tick();

    //if (this.status==Status.DONE)
    my_return = this.change_state();

    //else //not ready yet...
    //println("State " + this.name + " is not ready to change!");

    return my_return;
  }

  //tries to change the current state. returns the next state if it's time to change
  State change_state() {

    //if it' not done yet, not ready to change
    //if (this.status!=Status.DONE) {
      //println("State " + this.name + " is not ready to change!");
    //  return null;
    //}

    //if done, looks for the next state
    State next_state = null;

    //iterates over array
    for (Connection c : connections) {
      //looks if c's condition corresponds to the current input. if so changes the state
      if (c.is_condition_satisfied()) {
        next_state = c.get_next_state();

        //if it's going to another state
        if (next_state != this) {
          if (debug)
            println("State was " + this.name + " . Now it is changing to " + next_state.name);
          //interrupts current activities that are still going on
          this.interrupt();
          //refresh the next state
          next_state.refresh();
          //runs the next state
          next_state.run();
          break;
        }

        //if this is a transition to this very same state
        else {
          if (debug)
            println("this is a transition to self!!! state: " + this.name);
          //refreshes currently stopped tasks
          this.refresh_and_run_completed_tasks();
          break;
        }
      }
    }

    if (next_state==null)
      if (debug) println("State " + this.name + " doesn't have a connection for this input! this can be a bug!");

    return next_state;
  }


  //add a task t to this state
  void add_task(Task t) {
    tasks.addElement(t);
    if (debug)
      println("Task " + t.name + " added to state " + this.name);

    //updates the gui
    add_task_in_accordion_gui(t);
  }

  //remove a task t from this state
  void remove_task(Task t) {
    if (tasks.contains(t)) {
      //removes the physical task
      this.tasks.removeElement(t);
      //removes the task in gui
      this.remove_task_in_accordion_gui(t);
    } else
      if (debug) println("Unable to remove task " + t.name + " from state " + this.name);

    //updates the gui
    remove_task_in_accordion_gui(t);
  }

  //removes all tasks associated to this state
  void remove_all_tasks() {
    for (Task t : tasks)
      this.remove_task(t);
  }

  //add a connection to this state
  void connect(Expression expression, State next_state) {

    //in case the condition hasnt been used, create a new connection
    Connection c = new Connection(next_state, expression, connections.size());
    connections.addElement(c);
    if (debug)
      println("Connection created. If " + this.name + " receives " + expression.toString() + ", it goes to state " + next_state.name);
  }

  //creates a "anything else" connection to next_state
  void connect(State next_state) {
    this.connect(new Expression("true"), next_state);
  }

  //creates a "anything else" connection to self
  void connect_anything_else_to_self() {
    connect(this);
  }

  //remove a connection from this state
  void disconnect(Connection c) {
    if (connections.contains(c))
      this.connections.removeElement(c);
    else
      if (debug) println("Unable to remove connection " + c.toString() + " from state " + this.name);
  }

  int get_number_of_tasks() {
    return this.tasks.size();
  }


  /*******************************************
   ** GUI FUNCTIONS ***************************
   ********************************************/
  void draw() {
    update_cordinates_gui();
    draw_connections();
    draw_state();
  }

  //updates the current position of this state in screen
  void set_position_gui(int newx, int newy) {
    this.x = newx;
    this.y = newy;
  }

  //checks if a certain position (often the mouse) intersects this state in the screen
  boolean intersects_gui(int test_x, int test_y) {
    int dx = abs(test_x-x);
    int dy = abs(test_y-y);
    int R = size-25;

    return (dx*dx)+(dy*dy) <= R*R;
  }

  //aux variable to handle the state moving on the screen
  boolean moving = false;

  //updates the coords of the state in the screen in case mouse drags it
  void update_cordinates_gui() {
    //if mouse if moving
    if (mousePressed) {
      //if intersects for the first time
      if (this.intersects_gui(mouseX, mouseY) & !is_dragging_someone) {
        //set move equals true
        moving= true;
        is_dragging_someone = true;
      }

      //if is moving, updates the value
      if (moving)
        set_position_gui(mouseX, mouseY);
      //if mouse is released
    } else {
      //stops moving
      moving = false;
      is_dragging_someone = false;
    }
  }

  //updates the name of this state
  void update_name (String newName) {
    //removes the old gui label
    cp5.remove(this.name);
    //updates the name
    this.name = newName.toUpperCase();
    //creates a new gui element for it
    this.init_state_name_gui();
    //label.setFocus(false);
  }

  //inits gui elements related to controlP5
  void init_gui() {
    textSize(cp5.getFont().getSize());
    textFont(cp5.getFont().getFont());
    init_state_name_gui();
    init_accordion_gui();
    //init_tasks_gui();
  }

  void hide_gui() {
    label.hide();
    accordion.hide();
  }

  void show_gui() {
    label.show();
    accordion.show();
  }

  //inits the label with the name of the state
  void init_state_name_gui() {
    label = cp5.addTextfield(this.name)
      .setText(this.name)
      .setColorValue(color(255, 255))
      .setColorBackground(color(0, 255))
      .setColorForeground(color(0, 255))
      //.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER)
      .setWidth((int)(textWidth(this.name)*1.25))
      .setFocus(false)
      .setAutoClear(false)
      .setLabel("")
      .onReleaseOutside(new CallbackListener() {
                public void controlEvent(CallbackEvent theEvent) {
                  //if the user leaves the textfield without pressing enter
                  if (!label.getText().equalsIgnoreCase(name))
                    //resets the label
                    init_state_name_gui();
                }
              })
      ;
  }

  //init the accordion that will store the tasks
  void init_accordion_gui() {
    accordion = cp5.addAccordion("acc_"+this.name)
      .setWidth(110)
      //.hide()
      ;
  }

  //adds a task from the accordion
  void add_task_in_accordion_gui(Task t) {
    //creates a new group
    Group g = cp5.addGroup(this.name + " " + t.get_name())
      .setColorBackground(color(255, 50)) //color of the task
      .setBackgroundColor(color(255, 25)) //color of task when openned
      .setBackgroundHeight(50) //
      .setLabel(t.get_prefix() + "   " + t.get_name())
      ;

    cp5.addBang("bang_" + this.name + " " + t.get_name())
      .setPosition(10, 20)
      .setSize(10, 10)
      .moveTo(g)
      ;

    //adds this group to the accordion
    accordion.addItem(g);
  }

  //removes a task from the accordion
  void remove_task_in_accordion_gui(Task t) {
    //looks for the group
    Group g = cp5.get(Group.class, this.name + " " + t.get_name());
    //removes this task from the accordion
    accordion.removeItem(g);
  }

  //draws the status of this state
  void draw_status() {
    noStroke();

    if(is_actual)
    //if (status==Status.RUNNING)
    //if (status==Status.RUNNING | (status==Status.DONE & is_actual))
      fill (0, green+75, 0);
    else if (status==Status.DONE)
      fill (100, 0, 0);
    else if (status==Status.INACTIVE)
      fill (100);

    ellipse(x, y, size+25, size+25);

    //increments the status
    increment_status();
  }

  //aux variables for the gui
  float counter = 0, green = 0;

  void increment_status() {
    //incrementing the counter
    int limit = 32;
    if (counter < limit/2)
      green = green+limit/16;
    else
      green = green-limit/16;

    counter=(counter+1)%limit;
  }

  void draw_state() {
    //if keypressed, draws a connection
    //if (keyPressed)
    // draw_connections(mouseX, mouseY);

    //draws the status circle
    draw_status();

    //draws the main central ellipse
    noStroke();
    fill (0);
    ellipse(x, y, size, size);

    //prints info such as tasks and name
    move_gui();
  }

  void move_gui() {
    //moving the label
    label.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER);
    float textwidth = textWidth(name);
    textwidth = textwidth/2;
    label.setPosition(x-textwidth-(textwidth/5), y-7);


    //moving the tasks
    accordion.setPosition(x-(accordion.getWidth()/2), y+(size/2)+(size/4));
  }

  //draws additional info if this is a begin
  void draw_begin() {

    noFill();
    //stroke(green+25);
    stroke(50);
    //the wieght of the line
    strokeWeight(5);
    ellipse(x, y, size*2, size*2);
    //fill(green+25);
    fill(50);
    noStroke();
    textAlign(CENTER, CENTER);
    text("BEGIN", x, y-(size*1.2));
  }

  //draws additional info if this is an end
  void draw_end() {
    //line color
    noFill();
    //stroke(green+25);
    stroke(50);
    //the wieght of the line
    strokeWeight(5);
    ellipse(x, y, size*2, size*2);
    //fill(green+25);
    fill(50);
    noStroke();
    textAlign(CENTER, CENTER);
    text("END", x, y-(size*1.2));
  }

  //draws additional info if this is an end
  void draw_actual() {
    //line color
    noFill();
    stroke(green+25);
    //stroke(50);
    //the wieght of the line
    strokeWeight(5);
    ellipse(x, y, size*2.5, size*2.5);
    fill(green+25);
    //fill(50);
    noStroke();
    textAlign(CENTER, CENTER);
    text("ACTUAL", x, y-(size*1.5));
  }

  void draw_connections () {
    for (int i = 0; i < connections.size(); i++) {
      Connection c = connections.get(i);
    //for (Connection c : connections) {
      if (c.get_next_state().get_name() == this.get_name())
        draw_connection_to_self(c, i+1);

      else
        draw_connection(c, i+1);
    }
  }

  void draw_connection (Connection c, int priority) {
    State ns = c.get_next_state();
    //line color
    stroke(50);
    //the wieght of the line
    strokeWeight(5);
    //draws the line
    line(x, y, ns.x, ns.y);
    //saves the current matrix
    pushMatrix();
    //moving to where the arrow is going
    translate(x, y);
    //saves the current matrix
    pushMatrix();
    //computes the midpoint where the arrow is going to be
    float newx = (ns.x-x)/2;
    float newy = (ns.y-y)/2;
    //translate to the final position of the arrow
    translate(newx, newy);

    //saves the current matrix
    pushMatrix();

    //computes the angle to rotate the arrow
    float a = atan2(x-ns.x, ns.y-y);
    //rotates
    rotate(a);
    //draws the arr0w
    line(0, 0, -10, -10);
    line(0, 0, 10, -10);
    //returns the matris to the regular position
    popMatrix();
    //sets text color
    fill(180);
    textAlign(CENTER, CENTER);
    text("[ "+priority+" ] : " + c.get_expression().toString(), 0, -30);
    //returns the matris to the regular position
    popMatrix();
    popMatrix();
  }

  void draw_connection_to_self(Connection c, int priority) {
    //line color
    stroke(50);
    //the wieght of the line
    strokeWeight(5);
    //draws the lines
    line(x, y, x-100, y-100);
    line(x, y, x+100, y-100);
    line(x-100, y-100, x+100, y-100);
    //draw the arrow
    line(x-5, y-100, x+5, y-90);
    line(x-5, y-100, x+5, y-110);
    //draw the input
    fill(180);
    textAlign(CENTER, CENTER);
    text("[ "+priority+" ] : "  + c.get_expression().toString(), x, y-125);
  }
}
