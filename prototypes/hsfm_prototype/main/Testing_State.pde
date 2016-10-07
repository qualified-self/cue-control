/************************************************
 ** Basic file created to test the State Class
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

class Testing_State extends Testing {

  State s;
  AudioTask t1;
  OSCTask t2;
  
  public Testing_State(PApplet p) {
    super(p);
  }

  void setup() {
    s = new State("my first state!");

    Object[] m = {1, 2, 3, 4, "test", 3.4};

    t1 = new AudioTask(p, "Testing audio", "vibraphon.aiff");
    t2 = new OSCTask(p, "Testing OSC", 5000, "127.0.0.1", m); 

    s.add_task(t1);
    s.add_task(t2);
  }

  void draw() {
    s.update_status();

    switch(s.get_status()) {
    case INACTIVE:
      background(0, 0, 0);
      break;

    case RUNNING:
      background(0, 0, 255);
      break;

    case DONE:
      background(255, 0, 0);
      break;
    }
  }

  void mousePressed() {
    s.run();
  }
  void mouseReleased() {
    s.stop();
  }
}