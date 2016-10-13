/************************************************
 ** Basic file created to test the State_Machine Class
 ************************************************
 ** State machine designed based on our scenario 
 ************************************************
 ** jeraman.info, Oct. 7 2016 *******************
 ************************************************
 ************************************************/

class Scenario extends Testing {

  //check the diagram to get an idea of this struct according to our scenario

  //first level
  State_Machine root; 
  State wait_for_trigger;
  State main;

  //second level - part 1
  State_Machine environmental;
  State osc_loop;

  //second level - part 2
  State_Machine piece;
  State introduction;
  State self_appears;
  State sync;

  //third level (not sure)
  State_Machine light_control;
  State_Machine sound_control;

  //the tasks used in this scenario
  OSCTask   init;
  OSCTask   final_fadeout;
  OSCTask   update_vibropixel1, update_vibropixel2;
  OSCTask   update_bb;
  SetBBTask putMouseXValuesInBB;

  //input for debug
  Input i = Input.INIT;
  

  public Scenario(PApplet p) {
    super(p);
  }

  void init_tasks() {
    init               = new OSCTask(p, "switch/off", 5000, "127.0.0.1", new Object[]{0});
    final_fadeout      = new OSCTask(p, "fade/out", 5001, "127.0.0.1", new Object[]{1, 1});
    update_vibropixel1 = new OSCTask(p, "update/vibropixel/1", 5003, "127.0.0.1", new Object[]{0});
    update_vibropixel2 = new OSCTask(p, "update/vibropixel/2", 5004, "127.0.0.1", new Object[]{0});
    update_bb          = new OSCTask(p, "update/variables/blackboard", 5005, "127.0.0.1", new Object[]{0});

    putMouseXValuesInBB= new SetBBTask(p, "my_mouse_x", 100);
  }


  void setup() {
    init_tasks();
    setup_root();
    setup_environmental();
    setup_piece();
    root.show();  
    
    bb.add_item("Input", i);
    
    //root.run();
    println("the State_Machine is ready!");
  }

  
  
  void draw() {
    root.tick((Input)bb.get_value_by_name("Input"));
    root.update_status();
    root.draw();
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
    case ' ':
      root.run();
      break;
    case 's':
      root.stop();
      break;
    }
    
    bb.update_item("Input", i);
    //println("inputing " + i);
    //root.tick(i);
  }

  ////////////////////////////////////////////////
  //setting up root State_Machine - LEVEL 1
  void setup_root() {
    root_create_states();
    root_associate_tasks_to_state();
    root_create_connections_state();
  }

  void root_create_states() {
    root             = new State_Machine("MAIN_State_Machine");
    wait_for_trigger = new State("WAIT_FOR_TRIGGER");
    main             = new State("MAIN_STATE_FOR_THE_PIECE");
    environmental    = new State_Machine("ENVIRONMENTAL");
    piece            = new State_Machine("PIECE");

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
  //setting up enviromental State_Machine - LEVEL 2 - PART 1
  void setup_environmental() {
    environmental_create_states();
    environmental_associate_tasks_to_state();
    environmental_create_connections_state();
  }

  void environmental_create_states() {
    //environmental was already created!
    //environmental = new State_Machine("ENVIRONMENTAL_State_Machine");
    osc_loop      = new State("OSC_LOOP");
    environmental.add_state(osc_loop);
  }

  void environmental_associate_tasks_to_state () {
    osc_loop.add_task(update_vibropixel1);
    osc_loop.add_task(update_vibropixel2);
    osc_loop.add_task(putMouseXValuesInBB);
  }

  void environmental_create_connections_state () {
    environmental.begin.connect_via_all_inputs(osc_loop);
    osc_loop.connect(Input.FINISH, environmental.end);
    osc_loop.connect_via_all_unused_inputs(osc_loop);
    environmental.all_states_connect_to_finish_when_finished();
  }

  ////////////////////////////////////////////////
  //setting up piece State_Machine - LEVEL 2 - PART 2
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