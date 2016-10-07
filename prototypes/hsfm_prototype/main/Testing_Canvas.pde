/************************************************
 ** Basic file created to test the Canvas Class
 ************************************************
 ** State machine designed based on our scenario 
 ************************************************
 ** jeraman.info, Oct. 7 2016 *******************
 ************************************************
 ************************************************/

class Testing_Canvas extends Testing {

  //check the diagram to get an idea of this struct according to our scenario

  //first level
  Canvas root; 
  State wait_for_trigger;
  State main;

  //second level - part 1
  Canvas environmental;
  State osc_loop;

  //second level - part 2
  Canvas piece;
  State introduction;
  State self_appears;
  State sync;

  //third level (not sure)
  Canvas light_control;
  Canvas sound_control;

  //8 tasks: one per state, as an example
  OSCTask init;
  OSCTask final_fadeout;
  OSCTask update_vibropixel1, update_vibropixel2;
  OSCTask update_bb;
  OSCTask t2, t3, t4, t5, t6, t7, t8; 

  //input for debug
  Input i;

  public Testing_Canvas(PApplet p) {
    super(p);
  }

  void init_tasks() {
    init               = new OSCTask(p, "switch/off", 5000, "127.0.0.1", new Object[]{0});
    final_fadeout      = new OSCTask(p, "fade/out", 5001, "127.0.0.1", new Object[]{1, 1});
    update_vibropixel1 = new OSCTask(p, "update/vibropixel/1", 5003, "127.0.0.1", new Object[]{0});
    update_vibropixel2 = new OSCTask(p, "update/vibropixel/2", 5004, "127.0.0.1", new Object[]{0});
    update_bb          = new OSCTask(p, "update/variables/blackboard", 5005, "127.0.0.1", new Object[]{0});

    //t3 = new OSCTask(p, "start/main/loop", 5002, "127.0.0.1", new Object[]{1, 1, 1, 1});
    //t4 = new OSCTask(p, "update/vibropixel/1", 5003, "127.0.0.1", new Object[]{0});
    //t5 = new OSCTask(p, "update/vibropixel/2", 5004, "127.0.0.1", new Object[]{0});
    //t6 = new OSCTask(p, "update/variables/blackboard", 5005, "127.0.0.1", new Object[]{0});
    //t7 = new OSCTask(p, "update/dmx", 5006, "127.0.0.1", new Object[]{0});
    //t8 = new OSCTask(p, "update/sound", 5007, "127.0.0.1", new Object[]{0});
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
  }


  void setup() {
    init_tasks();
    setup_root();
    setup_environmental();
    setup_piece();
    root.run();
    println("the canvas is ready!");
  }

  void draw() {
    root.update_status();
    gui();
  }

  void keyPressed() {
    switch(key) {
    case '1':
      i = Input.START_MAIN_LOOP;
      break;
    case '2':
      i = Input.START_SELF_APPEARS;
      break;
    case '3':
      i = Input.DATA_SYNCED_OR_TIMEOUT;
      break;
    case '4':
      i = Input.FINISH;
      break;
    }
    println("inputing " + i);
    root.tick(i);
  }

  ////////////////////////////////////////////////
  //setting up root canvas - LEVEL 1
  void setup_root() {
    root_create_states();
    root_associate_tasks_to_state();
    root_create_connections_state();
  }

  void root_create_states() {
    root             = new Canvas("MAIN_CANVAS");
    wait_for_trigger = new State("WAIT_FOR_TRIGGER");
    main             = new State("MAIN_STATE_FOR_THE_PIECE");
    environmental    = new Canvas("ENVIRONMENTAL");
    piece            = new Canvas("PIECE");

    root.add_state(wait_for_trigger);
    root.add_state(main);
  }

  void root_associate_tasks_to_state () {
    root.add_initialization_task(init);
    root.add_finalization_task(final_fadeout);
    main.add_task(environmental);
    main.add_task(piece);
  }

  void root_create_connections_state () {
    root.begin.connect_via_all_inputs(wait_for_trigger);
    wait_for_trigger.connect(Input.START_MAIN_LOOP, main);
    wait_for_trigger.connect_via_all_unused_inputs(wait_for_trigger);
    main.connect_via_all_inputs(root.end);

    root.all_states_connect_to_finish_when_finished();
  }

  ////////////////////////////////////////////////
  //setting up enviromental canvas - LEVEL 2 - PART 1
  void setup_environmental() {
    environmental_create_states();
    environmental_associate_tasks_to_state();
    environmental_create_connections_state();
  }

  void environmental_create_states() {
    //environmental was already created!
    //environmental = new Canvas("ENVIRONMENTAL_CANVAS");
    osc_loop      = new State("OSC_LOOP");
    environmental.add_state(osc_loop);
  }

  void environmental_associate_tasks_to_state () {
    osc_loop.add_task(update_vibropixel1);
    osc_loop.add_task(update_vibropixel2);
  }

  void environmental_create_connections_state () {
    environmental.begin.connect_via_all_inputs(osc_loop);
    osc_loop.connect(Input.FINISH, environmental.end);
    osc_loop.connect_via_all_unused_inputs(osc_loop);
    environmental.all_states_connect_to_finish_when_finished();
  }

  ////////////////////////////////////////////////
  //setting up piece canvas - LEVEL 2 - PART 2
  void setup_piece() {
    piece_create_states();
    piece_associate_tasks_to_state();
    piece_create_connections_state();
  }

  void piece_create_states() {
    introduction = new State("INTRODUCTION");
    self_appears = new State("SELF_APPEARS");
    sync         = new State("SYNC");
    //piece was already created!
    piece.add_state(introduction);
    piece.add_state(self_appears);
    piece.add_state(sync);
  }

  void piece_associate_tasks_to_state () {
    introduction.add_task(update_bb);
    self_appears.add_task(update_bb);
    sync.add_task(update_bb);
  }

  void piece_create_connections_state () {
    piece.begin.connect_via_all_inputs(introduction);
    introduction.connect(Input.START_SELF_APPEARS, self_appears);
    introduction.connect_via_all_unused_inputs(introduction);
    self_appears.connect(Input.DATA_SYNCED_OR_TIMEOUT, sync);
    self_appears.connect_via_all_unused_inputs(self_appears);
    sync.connect(Input.FINISH, piece.end);
    sync.connect_via_all_unused_inputs(sync);
    piece.all_states_connect_to_finish_when_finished();
  }
}