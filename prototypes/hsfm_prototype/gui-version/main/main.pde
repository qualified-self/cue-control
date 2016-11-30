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
Canvas t      = new Canvas();
Blackboard bb = new Blackboard();

boolean debug = false;
boolean keyReleased = false;
boolean mouseReleased = false;

void setup() {
  size(1024, 748);
  background(0);
  smooth();
  setup_util();
  t.setup();
  bb.set_gui_position(width-(bb.mywidth*3)-2, 20);
}

void draw() {
  //updates global variables in the bb
  bb.update_global_variables();
  //draws the scenario
  t.draw();
  //draws the blackboard
  bb.draw();

  if (keyReleased)     keyReleased = false;
  if (mouseReleased) mouseReleased = false;
}

void keyPressed() {
  t.keyPressed();
}

void mousePressed() {
  t.mousePressed();
}

void keyReleased() {
  keyReleased = true;
}

void mouseReleased() {
  mouseReleased = true;
}