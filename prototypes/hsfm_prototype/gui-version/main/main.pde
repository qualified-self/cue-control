/************************************************
 ** My main!
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/



//Testing_Task          t = new Testing_Task(this);
//Testing_State         t = new Testing_State(this);
//Testing_Connection    t = new Testing_Connection(this);
//Scenario t = new Scenario(this);
//Testing_Conditions    t = new Testing_Conditions(this);
//Scenario t    = new Scenario(this);
Canvas    canvas      = new Canvas();
Blackboard board      = new Blackboard();
Serializer serializer = new Serializer();

boolean debug = false;
boolean keyReleased = false;
boolean mouseReleased = false;

void setup() {
  size(1280, 800);
  background(0);
  smooth();
  setup_util();
  canvas.setup();
  board.set_gui_position(width-(board.mywidth*3)-2, 20);
}

void draw() {
  //updates global variables in the bb
  board.update_global_variables();
  //draws the scenario
  canvas.draw();
  //draws the blackboard
  board.draw();

  if (keyReleased)     keyReleased = false;
  if (mouseReleased) mouseReleased = false;
}

void keyPressed(){
  switch(key) {
  case '+':
    //create_state();
    canvas.process_plus_key_pressed();
    break;
  case '-':
    //remove_state();
    canvas.process_minus_key_pressed();
    break;
  case ' ':
    canvas.run();
    break;
  case 's':
    canvas.stop();
    break;
  case 'z':
    serializer.save();
    break;
  case 'x':
    serializer.load();
    break;
  }
  //println(keyCode);
}

void mousePressed() {
  //if the key is not pressed, i'm not interested
  if (!keyPressed) return;

  switch(keyCode) {
  //in case the key it's shift
  case 16:
    canvas.process_shift_key();
    break;
  }
}

void keyReleased() {
  keyReleased = true;
}

void mouseReleased() {
  mouseReleased = true;
}
