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