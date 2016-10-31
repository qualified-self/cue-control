/************************************************
 ** My main!
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

//Testing_Task          t = new Testing_Task(this);
//Testing_State         t = new Testing_State(this);
//Testing_Connection    t = new Testing_Connection(this);
Scenario t = new Scenario(this);


void setup() {
  size(1024, 748);
  background(0);
  smooth();
  setup_util();
  setup_blackboard();
  
  t.setup();
}

void draw() {
  t.draw();
  draw_blackboard();
}
  
void mousePressed() {
  t.mousePressed();
}

void mouseMoved() {
  t.mouseMoved();
}

void mouseReleased() {
  t.mouseReleased();
}

void keyPressed() {
  t.keyPressed();
}

//@TODO - integrate that with the Blackboard
//adding input osc support similar to Sofian's
void oscEvent(OscMessage msg) {
  t.oscEvent(msg);
}