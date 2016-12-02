/************************************************
 ** My canvas class! ****************************
 ************************************************
 ** jeraman.info, Nov. 23 2016 ******************
 ************************************************
 ************************************************/

 import java.io.Serializable;
 import processing.core.PApplet;
 import controlP5.*;
 import java.util.Vector;

class MainCanvas implements Serializable {

  StateMachine  root; //my basic state machine
  //Vector<State> states; //vector that store my states

  transient private PApplet p;
  transient private ControlP5 cp5;


  //contructor
  public MainCanvas (PApplet p, ControlP5 cp5) {
    this.p = p;
    this.cp5 = cp5;
  }

  void build(PApplet p, ControlP5 cp5) {
    System.out.println("@TODO [CANVAS] verify what sorts of things needs to be initialize when loaded from file");
    this.p = p;
    this.cp5 = cp5;
    root.build(p, cp5);
    //root.show();
  }

  //init my variables
  void setup(){

    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    root      = new StateMachine(this.p, cp5, "root");

    p.textSize(cp5.getFont().getSize());
    p.textFont(cp5.getFont().getFont());

    root.show();
  }

  //draw method
  void draw(){
    //executes the hfsm
    root.tick();

    //drawing the root
    root.show();
    root.draw();
    p.fill(255);
    p.textAlign(p.LEFT);
    p.text("ROOT", 20, 20);
  }

  //creates a new state and adds its to the root state machine
  void create_state() {
    System.out.println("creates a state");
    State newState = new State(p, cp5, "NEW_STATE_" + ((int)p.random(0, 1000)), p.mouseX, p.mouseY);
    root.add_state(newState);
  }

  //gets the state where the mouse is hoving and removes it form the root state machine
  void remove_state() {
    System.out.println("remove a state");
    root.remove_state(p.mouseX, p.mouseY);

  }

  void clear() {
    root.clear();
  }

  void run() {
    root.run();
  }

  void stop() {
    root.end.run();
    root.stop();
  }

  //processes the multiple interpretations of the '+' key
  void process_plus_key_pressed() {

    //reinit any name the user was trying to change it
    root.reset_all_names_gui();

    //verifies if the mouse intersects a state
    State result = root.intersects_gui(p.mouseX, p.mouseY);

    //if it does not, creates a new state
    if (result==null)
      create_state();
    //otherwise, opens the pie menu
    else
      //shows the pie
      result.show_pie();

  }

  //processes the multiple interpretations of the '-' key
  void process_minus_key_pressed() {

    //reinit any name the user was trying to change it
    root.reset_all_names_gui();

    //verifies if the mouse intersects a state
    State result = root.intersects_gui(p.mouseX, p.mouseY);

    //if it intersects no one, return
    if (result==null) return;

    //first tries to close the pie menu
    if (result.is_pie_menu_open())
      result.hide_pie();
    //otherwise, removes the state
    else
      remove_state();
  }

  //processes ui in case the shfit key was pressed
  void process_shift_key() {
    //verifies if the mouse intersects a state
    State result = root.intersects_gui(p.mouseX, p.mouseY);

    //if it does not, creates a new state
    if (result!=null) {
        System.out.println("mouse was pressed while holding shift key in state " + result.get_name());
        result.freeze_movement_and_trigger_connection();
    }
  }

}
