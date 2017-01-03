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
  StateMachine root;
  State wait_for_trigger;
  State main;

  //second level - part 1
  StateMachine environmental;
  State osc_loop;

  //second level - part 2
  StateMachine piece;
  State introduction;
  State self_appears;
  State sync;

  //third level (not sure)
  StateMachine light_control;
  StateMachine sound_control;

  //the tasks used in this scenario
  OSCTask   init;
  OSCTask   final_fadeout;
  OSCTask   update_vibropixel1, update_vibropixel2;
  OSCTask   update_bb;
  //SetBBTask putMouseXValuesInBB;
  AudioTask go123;

  //input for debug
  Input i = Input.INIT;

  //the most recent state
  int what_state_machine_is_showing = 0;


  public Scenario(PApplet p) {
    super(p);
  }

  void init_tasks() {
    init               = new OSCTask(p, "/switch/off", 5000, "127.0.0.1", new Object[]{0});
    final_fadeout      = new OSCTask(p, "/fade/out", 5001, "127.0.0.1", new Object[]{1, 1});
    update_vibropixel1 = new OSCTask(p, "/update/vibropixel/1", 5003, "127.0.0.1", new Object[]{0});
    update_vibropixel2 = new OSCTask(p, "/update/vibropixel/2", 5004, "127.0.0.1", new Object[]{0});
    update_bb          = new OSCTask(p, "/update/variables/blackboard", 5005, "127.0.0.1", new Object[]{0});

    //putMouseXValuesInBB= new SetBBTask(p, "my_mouse_x", mouseX);

    go123              = new AudioTask(p, "Playing sound!", "123go.mp3");

    setup_media_message();
  }


  void setup() {
    init_tasks();
    setup_root();
    setup_environmental();
    setup_piece();

    //hide_all();
    root.show();

    bb.put("Input", i);

    //root.run();
    println("the State_Machine is ready!");
  }


  void draw() {
    root.tick((Input)bb.get("Input"));
    root.update_status();

    draw_proper_state_machine();
  }


  void draw_proper_state_machine() {
    switch(what_state_machine_is_showing) {
    case 0:
      environmental.hide();
      piece.hide();
      root.show();
      root.draw();
      fill(255);
      //textSize(20);
      textAlign(LEFT);
      text("ROOT", 20, 20);
      break;
    case 1:
      root.hide();
      piece.hide();
      environmental.show();
      environmental.draw();
      fill(255);
      textAlign(LEFT);
      text("ROOT > ENVIRONMENTAL", 20, 20);
      break;
    case 2:
      root.hide();
      environmental.hide();
      piece.show();
      piece.draw();
      fill(255);
      textAlign(LEFT);
      text("ROOT > PIECE", 20, 20);
      break;
    }
  }

  void keyPressed() {
    switch(key) {
    case 'q':
      i = Input.START_MAIN_LOOP;
      break;
    case 'w':
      i = Input.START_SELF_APPEARS;
      break;
    case 'e':
      i = Input.DATA_SYNCED_OR_TIMEOUT;
      break;
    case 'r':
      i = Input.FINISH;
      break;

    case '1':
      what_state_machine_is_showing = 0;
      break;
    case '2':
      what_state_machine_is_showing = 1;
      break;
    case '3':
      what_state_machine_is_showing = 2;
      break;

    case ' ':
      root.run();
      break;
    case 's':
      root.stop();
      break;
    }

    bb.put("Input", i);
  }


  void mouseMoved() {

    mouseXPos.update_value((float)p.mouseX/width);
  }


  ////////////////////////////////////////////////
  //setting up root State_Machine - LEVEL 1
  void setup_root() {
    root_create_states();
    root_associate_tasks_to_state();
    root_create_connections_state();
  }

  void root_create_states() {
    root             = new StateMachine("MAIN_State_Machine");
    wait_for_trigger = new State("WAIT_FOR_TRIGGER");
    main             = new State("MAIN_STATE_FOR_THE_PIECE");
    environmental    = new StateMachine("ENVIRONMENTAL");
    piece            = new StateMachine("PIECE");

    root.add_state(wait_for_trigger);
    root.add_state(main);
  }

  void root_associate_tasks_to_state () {
    root.add_initialization_task(init);
    root.add_initialization_task(go123);
    root.add_finalization_task(final_fadeout);
    main.add_task(environmental);
    main.add_task(piece);

    //testing tasks
    wait_for_trigger.add_task(mouseXPos);
    wait_for_trigger.add_task(mouseXPosTimes2);

    root.add_initialization_task(speaker_enable);
    wait_for_trigger.add_task(aura_amp);
    wait_for_trigger.add_task(speaker_amp);
    wait_for_trigger.add_task(dmx_intensity);
    wait_for_trigger.add_task(dmx_duration);
    wait_for_trigger.add_task(dmx_rate);
  }

  void root_create_connections_state () {
    root.begin.connect_via_all_inputs(wait_for_trigger);
    wait_for_trigger.connect(Input.START_MAIN_LOOP, main);
    wait_for_trigger.connect_via_all_unused_inputs(wait_for_trigger);
    main.connect_via_all_inputs(root.end);

    //root.all_states_connect_to_finish_when_finished();
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
    osc_loop.add_task(mouseXPos);
  }

  void environmental_create_connections_state () {
    environmental.begin.connect_via_all_inputs(osc_loop);
    osc_loop.connect(Input.FINISH, environmental.end);
    osc_loop.connect_via_all_unused_inputs(osc_loop);
    //environmental.all_states_connect_to_finish_when_finished();
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
    //piece.all_states_connect_to_finish_when_finished();
  }

  //debug!
  //used for testing
  SetBBTask mouseXPos;
  SetBBTask mouseXPosTimes2;
  OSCTask aura_amp;
  OSCTask speaker_enable;
  OSCTask speaker_amp;
  OSCTask dmx_intensity;
  OSCTask dmx_duration;
  OSCTask dmx_rate;


  void setup_media_message () {
    mouseXPos        = new SetBBTask(p, "mouse_x", 0);

    //creating a new expression using the mouse_x variable
    Expression expr  = new Expression("$mouse_x*2");

    //feeding a new variable (mouseXPosTimes2) in the blackboard using the previous variable
    mouseXPosTimes2  = new SetBBTask(p, "mouse_x2", expr);

    Expression expr2  = new Expression("$mouse_x2*180");
    Expression expr3  = new Expression("$mouse_x2*255");
    // Expression expr2  = new Expression("(${bitalino_0}/1000) * 180");
    // Expression expr3  = new Expression("(${bitalino_0}/1000) * 255");

    aura_amp         = new OSCTask(p, "/aura/amp/0", 12000, "192.168.1.100", new Object[]{expr2});
    speaker_enable   = new OSCTask(p, "/speaker/enable", 12000, "192.168.1.100", new Object[]{1});
    speaker_amp      = new OSCTask(p, "/speaker/amp/0", 12000, "192.168.1.100", new Object[]{expr3});
    dmx_intensity    = new OSCTask(p, "/dmx/intensity", 12000, "192.168.1.100", new Object[]{expr2});
    dmx_duration     = new OSCTask(p, "/dmx/duration", 12000, "192.168.1.100", new Object[]{expr3});
    dmx_rate         = new OSCTask(p, "/dmx/rate", 12000, "192.168.1.100", new Object[]{expr3});
  }

}
