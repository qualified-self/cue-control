/************************************************
 ** My canvas class! ****************************
 ************************************************
 ** jeraman.info, Nov. 23 2016 ******************
 ************************************************
 ************************************************/

class Canvas {


  PApplet       p;    //my PApplet
  StateMachine  root; //my basic state machine
  Vector<State> states; //vector that store my states

  //contructor
  public Canvas (PApplet p) {
    this.p = p;
  }

  //init my variables
  void setup(){
    root      = new StateMachine(this.p, "root");
    states    = new Vector<State>();

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

  void keyPressed(){
    switch(key) {
    case '+':
      create_state();
      break;
    case '-':
      remove_state();
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
