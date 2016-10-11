/************************************************
 ** My main!
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

//Testing_Task          t = new Testing_Task(this);
//Testing_State         t = new Testing_State(this);
//Testing_Connection    t = new Testing_Connection(this);
//Testing_State_Machine t = new Testing_State_Machine(this);
Testing_Blackboard    t = new Testing_Blackboard(this);

void setup() {
  size(200, 200);
  setup_osc();
  t.setup();
}

void draw() {
  t.draw();
}

void mousePressed() {
  t.mousePressed();
}

void mouseReleased() {
  t.mouseReleased();
}

void keyPressed() {
  t.keyPressed();
}