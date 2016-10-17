/************************************************
 ** Generic abstract class for testing **********
 ************************************************
 ** jeraman.info, Oct. 3 2016 *******************
 ************************************************
 ************************************************/


abstract class Testing {
  
  PApplet p;
  
  Testing(PApplet p) {
    this.p = p;
  }
  
  abstract void setup();
  abstract void draw();
  void mousePressed(){}
  void mouseReleased(){}
  void mouseMoved() {}
  void keyPressed() {}
}



/************************************************
 ** Basic file created to test the Connection Class
 ************************************************
 ** State machine designed: *********************
 ** https://en.wikipedia.org/wiki/File:Turnstile_state_machine_colored.svg
 ************************************************
 ** jeraman.info, Oct. 3 2016 *******************
 ************************************************
 ************************************************/


class Testing_Connection extends Testing {
  State root; 

  State locked, unlocked, end;
  Connection c1, c2, c3, c4;

  AudioTask t1;
  OSCTask t2, t3;
  
  Input i;

  public Testing_Connection(PApplet p) {
    super(p);
  }

  void setup() {
    locked   = new State("locked!");
    unlocked = new State("unlocked!");
    end = new State("The end!");

    t1 = new AudioTask(p, "Playing sound!", "vibraphon.aiff");
    t2 = new OSCTask(p, "Sending OSC!", 5000, "127.0.0.1", new Object[]{1, 2, 3, 4, "test", 3.4});
    t3 = new OSCTask(p, "Sending another OSC!", 5000, "127.0.0.1", new Object[]{'a', 'b'});

    adding_tasks();
    creating_connections();

    root = locked;
    root.run();

    println("the FSM is ready!");
  }

  void adding_tasks() {
    locked.add_task(t2);
    locked.add_task(t2);

    unlocked.add_task(t3);
    unlocked.add_task(t3);
    
    end.add_task(t1);
  }

  void creating_connections () {
    
    locked.connect(Input.PUSH, locked);
    locked.connect(Input.COIN, unlocked);
    locked.connect_via_all_unused_inputs(end);
   
    unlocked.connect(Input.PUSH, locked);
    unlocked.connect(Input.COIN, unlocked);
    unlocked.connect_via_all_unused_inputs(end);
    
    end.connect_via_all_inputs(end);
  }

  void draw() {
    root.update_status();
    gui();
  }

  void gui() {
    //drawing background
    switch(root.get_status()) {
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

    //drawing text
    textSize(32);
    textAlign(CENTER);
    fill(100, 100, 100);
    text(root.name, width/2, height/2);

    //drawing input
    if (mousePressed) {
      textSize(17);
      textAlign(CENTER);
      fill(255, 355, 355);
      text("input was: " + i.toString(), width/2, (height/2)+50);
    }
  }

  void mousePressed() {
    int chances = int(random(11));

    if (chances < 5) { //if push.. 
      i = Input.PUSH;
      println("input: PUSH!");
    } else if (chances < 10){
      i = Input.COIN;
      println("input: COIN!");
    } else {
      i = Input.START_MAIN_LOOP;
      println("input: anything else that raises the isolated state!");
    }

    root = root.tick(i);
  }
}


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