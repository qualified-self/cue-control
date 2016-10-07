/************************************************
 ** Basic file created to test the Task Class
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

class Testing_Task extends Testing {

  AudioTask at;
  OSCTask ot;
  
  public Testing_Task(PApplet p) {
    super(p);
  };

  void setup() {
    Object[] m = {1, "test", 3.4};

    at = new AudioTask(p, "Testing audio", "vibraphon.aiff");
    ot = new OSCTask(p, "Testing OSC", 5000, "127.0.0.1", m); 
    at.run();
    ot.run();
  }

  void draw () {
    at.update_status();
    ot.update_status();

    switch(at.get_status()) {
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
    Object[] m = {mouseX, mouseY};
    ot.update_message(m);
    ot.run();
  }
}