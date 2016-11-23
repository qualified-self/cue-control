/************************************************
 ** Testing conditional transitions *************
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

class TestingConditions {

  PApplet p;
  StateMachine sm;
  SetBBTask mouseXPos;
  State a, b;


  public TestingConditions (PApplet p) {
    this.p = p;
  }

  void setup(){
    sm        = new StateMachine(p, "ROOT");
    mouseXPos = new SetBBTask(p, "mouse_x", 0);
    a  = new State("a");
    b  = new State("b");
    //c  = new State("c");

    sm.add_state(a);
    sm.add_state(b);
    //sm.add_state(c);
    sm.begin.connect(new Expression("$mouse_x>300"), a);
    sm.begin.connect_anything_else_to_self();

           a.connect(new Expression("$mouse_x>500"), b);
           a.connect(new Expression("$mouse_x<10"), sm.begin);
           a.connect_anything_else_to_self();

           b.connect(new Expression("$mouse_x>700"), sm.end);
           b.connect_anything_else_to_self();


    sm.begin.connect_anything_else_to_self();

    sm.begin.add_task(mouseXPos);
    a.add_task(mouseXPos);
    b.add_task(mouseXPos);
    sm.end.add_task(mouseXPos);

    sm.show();
  }

  void draw(){
    //executes the hfsm
    sm.tick();
    //and draw
    sm.draw();
  }

  void keyPressed() {
    switch(key) {
    case ' ':
      sm.run();
      break;
    case 's':
      sm.stop();
      break;
    }
  }

  void mouseMoved() {
    mouseXPos.update_value((float)p.mouseX);
  }
}
