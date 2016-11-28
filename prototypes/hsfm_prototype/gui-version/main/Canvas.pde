/************************************************
 ** My canvas class! ****************************
 ************************************************
 ** jeraman.info, Nov. 23 2016 ******************
 ************************************************
 ************************************************/



class Canvas {

  StateMachine  root; //my basic state machine
  Vector<State> states; //vector that store my states

  //contructor
  public Canvas () {

  }

  //init my variables
  void setup(){
    root      = new StateMachine("root");
    states    = new Vector<State>();

    textSize(cp5.getFont().getSize());
    textFont(cp5.getFont().getFont());

    root.show();
  }

  //draw method
  void draw(){
    //executes the hfsm
    root.tick();

    //drawing the root
    root.show();
    root.draw();
    fill(255);
    textAlign(LEFT);
    text("ROOT", 20, 20);
  }

  //creates a new state and adds its to the root state machine
  void create_state() {
    println("creates a state");
    State newState = new State("NEW_STATE_" + ((int)random(0, 1000)), mouseX, mouseY);
    root.add_state(newState);
  }

  //gets the state where the mouse is hoving and removes it form the root state machine
  void remove_state() {
    println("remove a state");
    root.remove_state(mouseX, mouseY);

  }

  //processes the multiple interpretations of the '+' key
  void process_plus_key_pressed() {

    //reinit any name the user was trying to change it
    root.reset_all_names_gui();

    //verifies if the mouse intersects a state
    State result = root.intersects_gui(mouseX, mouseY);

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
    State result = root.intersects_gui(mouseX, mouseY);

    //if it intersects no one, return
    if (result==null) return;

    //first tries to close the pie menu
    if (result.is_pie_menu_open())
      result.hide_pie();
    //otherwise, removes the state
    else
      remove_state();

  }

  void keyPressed(){
    switch(key) {
    case '+':
      //create_state();
      process_plus_key_pressed();
      break;
    case '-':
      //remove_state();
      process_minus_key_pressed();
      break;
    case ' ':
      root.run();
      break;
    case 's':
      root.end.run();
      root.stop();
      break;
    }
  }
}

//processes the text field related to the states
void controlEvent(ControlEvent theEvent) {
  //println("isGroup() "+ theEvent.isTab());
  //println("isTab() "+ theEvent.isTab());
  //println("getTab() "+ theEvent.getTab());
  //println("getGroup() "+ theEvent.getGroup());

  if(theEvent.isAssignableFrom(Textfield.class)) {
    String oldName = theEvent.getName();
    String newName = theEvent.getStringValue();

    //checks if there is already a state with the very same future name
    State is_there_a_state_with_the_new_name = t.root.get_state_by_name(newName);
    State result                             = t.root.get_state_by_name(oldName);

    //if there is, prints an error and change does not occur!
    if (is_there_a_state_with_the_new_name != null) {
      println("There is alrealdy a state with this same name. Please, pick another name!");
      result.update_name(oldName);
      return;
    }

    if (result != null)
      result.update_name(newName);
    else
      println("a state with name " + oldName + " could not be found! ");
  }

  /*
  if (theEvent.isGroup()) {
    println("got an event from group "
      +theEvent.getGroup().getName()
      +", isOpen? "+theEvent.getGroup().isOpen()
      );
  } else if (theEvent.isController()) {
    println("got something from a controller "
      +theEvent.getController().getName()
      );
  }
  */

}
