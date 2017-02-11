/************************************************
 ** Testing conditional transitions *************
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/



class Scenario {

  //my PApplet
  PApplet p;

  //my basic state machine
  StateMachine root;
  State        intro, self_appears, sync, outro;

  //my tasks (including sub state machines)
  StateMachine sync_tester;
  State        counting;

  //light control state machines
  StateMachine light_control;
  State        config_1, config_2, config_3;

  String dest_ip = "192.168.1.10";

  /*
  //setup
  OSCTask      begin_speaker_enable;
  OSCTask      begin_ambient_silence;
  OSCTask      begin_heart_silence;
  OSCTask      begin_aura_silence;
  //intro
  OSCTask      intro_ambient_increase;
  OSCTask      intro_aura_increase;
  //the self appears
  OSCTask      selfa_ambient_silence;
  OSCTask      selfa_aura_silence;
  OSCTask      selfa_heart_starts;
  //sync
  OSCTask      sync_ambient_stable;
  OSCTask      sync_heart_increase;
  OSCTask      sync_aura_increase;
  //outro
  OSCTask      outro_ambient_fades;
  OSCTask      outro_heart_fades;
  OSCTask      outro_aura_fades;

  OSCTask      end_speaker_enable;
  OSCTask      end_ambient_silence;
  OSCTask      end_heart_silence;
  OSCTask      end_aura_silence;
*/

  int what_state_machine_is_showing = 0;

  //contructor
  public Scenario (PApplet p) {
    this.p = p;
  }

  void setup(){

    //init states
    root          = new StateMachine(this.p, "root");
    intro         = new State("intro");
    self_appears  = new State("self_appears");
    sync          = new State("sync");
    outro         = new State("outro");

    //adding them to the basic state machine
    root.add_state(intro);
    root.add_state(self_appears);
    root.add_state(sync);
    root.add_state(outro);

    //making the proper connections
    //root.begin.connect(new Expression("( $keyPressed && ($key == j && $mouseX > 400) )"), intro);
    //oot.begin.connect(new Expression("$keyPressed && $key == j"), intro);
    //root.begin.connect(new Expression("$keyPressed && $mouseX > 400 && $mouseY > 300"), intro);
    root.begin.connect(new Expression("$keyPressed"), intro);
    root.begin.connect_anything_else_to_self();

    intro.connect(new Expression("$root_stateTimer > 30"), self_appears);
    intro.connect_anything_else_to_self();

    self_appears.connect(new Expression("$root_stateTimer > 30"), sync);
    self_appears.connect_anything_else_to_self();

    //Expression complex_one = new Expression("($root_stateTimer > 5) && ($in_sync)");
    //Expression complex_one = new Expression("($root_stateTimer > 30) && ( ($in_sync) || ($root_stateTimer > 40) )");
    Expression complex_one = new Expression("($root_stateTimer > 30) && ($in_sync)");
    //Expression complex_one = new Expression("$in_sync");
    sync.connect(complex_one, outro);
    sync.connect_anything_else_to_self();

    outro.connect(new Expression("$root_stateTimer > 30"), root.end);
    outro.connect_anything_else_to_self();

    ///////////////////////////////////////////////
    //init the tasks.

    //first, the [s_m] in sync tester. creating objects
    sync_tester = new StateMachine(p,"sync_tester");
    counting    = new State("counting");
    //adding the counting state to this state machine
    sync_tester.add_state(counting);
    //making the connections
    sync_tester.begin.connect(new Expression("$mouseX > 400"), counting);
    sync_tester.begin.connect_anything_else_to_self();
    counting.connect(new Expression("$sync_tester_stateTimer > 10"), sync_tester.end);
    counting.connect(new Expression("$mouseX > 400"), counting);
    counting.connect(sync_tester.begin);
    //sync_tester.end.connect(sync_tester.end);

    //than, the in_sync boolean
    SetBBTask flagInSync = new SetBBTask(p, "in_sync", true);

    //adding the tasks to their corresponding states
    sync.add_task(sync_tester);
    sync_tester.end.add_task(flagInSync);

    //setting up tasks
    load_tasks ();

    root.show();
  }

  void load_tasks () {
    //creating a new expression using the mouse_x variable
    Expression inc_timer       = new Expression("(($root_stateTimer/30)%1)");
    Expression inc_timer_high  = new Expression("(($root_stateTimer/60)%1)+0.5");
    Expression fadeout         = new Expression("((30.-$root_stateTimer)/30.)");
    //Expression expr2  = new Expression("$mouse_x2*180");
    //Expression expr3  = new Expression("$mouse_x2*255");
    // Expression expr2  = new Expression("(${bitalino_0}/1000) * 180");
    // Expression expr3  = new Expression("(${bitalino_0}/1000) * 255");

    //tasks for the state setup
    //OSCTask begin_speaker_disable   = new OSCTask(p, "/speaker/enable", 12000, dest_ip, new Object[]{0});
    OSCTask begin_speaker_enable   = new OSCTask(p, "/speaker/enable", 12000, dest_ip, new Object[]{1.});
    OSCTask begin_ambient_silence  = new OSCTask(p, "/speaker/amp/1", 12000, dest_ip, new Object[]{0.});
    OSCTask begin_heart_silence    = new OSCTask(p, "/speaker/amp/0", 12000, dest_ip, new Object[]{0.});
    OSCTask begin_aura_silence     = new OSCTask(p, "/aura/amp/0", 12000, dest_ip, new Object[]{0.});
    OSCTask begin_dmx_silence        = new OSCTask(p, "/dmx/enable", 12000, dest_ip, new Object[]{0.});
    //root.begin.add_task(begin_speaker_disable);
    root.begin.add_task(begin_speaker_enable);
    root.begin.add_task(begin_ambient_silence);
    root.begin.add_task(begin_heart_silence);
    root.begin.add_task(begin_aura_silence);
    root.begin.add_task(begin_dmx_silence);

    //taks for the state intro
    OSCTask intro_ambient_increase = new OSCTask(p, "/speaker/amp/1", 12000, dest_ip, new Object[]{inc_timer});
    OSCTask intro_aura_increase    = new OSCTask(p, "/aura/amp/0", 12000, dest_ip, new Object[]{inc_timer});
    intro.add_task(intro_ambient_increase);
    intro.add_task(intro_aura_increase);

    //tasks for the stage the self appears
    OSCTask selfa_aura_silence     = begin_aura_silence.clone();
    OSCTask selfa_ambient_silence  = begin_ambient_silence.clone();
    OSCTask selfa_heart_starts     = new OSCTask(p, "/speaker/amp/0", 12000, dest_ip, new Object[]{1.});
    //loading light control state machine
    load_light_control_state_machine();

    self_appears.add_task(selfa_ambient_silence);
    self_appears.add_task(selfa_aura_silence);
    self_appears.add_task(selfa_heart_starts);
    self_appears.add_task(light_control);


    //tasks for the sync state
    OSCTask sync_ambient_stable    = new OSCTask(p, "/speaker/amp/1", 12000, dest_ip, new Object[]{inc_timer_high});
    OSCTask sync_heart_increase    = new OSCTask(p, "/speaker/amp/0", 12000, dest_ip, new Object[]{inc_timer_high});
    OSCTask sync_aura_increase     = new OSCTask(p, "/aura/amp/0", 12000, dest_ip, new Object[]{inc_timer_high});
    sync.add_task(sync_ambient_stable);
    sync.add_task(sync_heart_increase);
    sync.add_task(sync_aura_increase);
    //tasks for the outro state
    OSCTask outro_ambient_fades    = new OSCTask(p, "/speaker/amp/1", 12000, dest_ip, new Object[]{fadeout});
    OSCTask outro_heart_fades      = new OSCTask(p, "/speaker/amp/0", 12000, dest_ip, new Object[]{fadeout});
    OSCTask outro_aura_fades       = new OSCTask(p, "/aura/amp/0", 12000, dest_ip, new Object[]{fadeout});
    OSCTask outro_dmx_i_fades      = new OSCTask(p, "/dmx/intensity", 12000, dest_ip, new Object[]{fadeout});
    OSCTask outro_dmx_d_fades      = new OSCTask(p, "/dmx/duration", 12000, dest_ip, new Object[]{fadeout});
    OSCTask outro_dmx_r_fades      = new OSCTask(p, "/dmx/rate", 12000, dest_ip, new Object[]{fadeout});
    outro.add_task(outro_ambient_fades);
    outro.add_task(outro_heart_fades);
    outro.add_task(outro_aura_fades);
    outro.add_task(outro_dmx_i_fades);
    outro.add_task(outro_dmx_d_fades);
    outro.add_task(outro_dmx_r_fades);
    //tasks for the root.end
    OSCTask end_speaker_enable     = new OSCTask(p, "/speaker/enable", 12000, dest_ip, new Object[]{0});
    OSCTask end_ambient_silence    = new OSCTask(p, "/speaker/amp/1", 12000, dest_ip, new Object[]{0});
    OSCTask end_heart_silence      = new OSCTask(p, "/speaker/amp/0", 12000, dest_ip, new Object[]{0});
    OSCTask end_aura_silence       = new OSCTask(p, "/aura/amp/0", 12000, dest_ip, new Object[]{0});
    OSCTask end_dmx_silence        = new OSCTask(p, "/dmx/enable", 12000, dest_ip, new Object[]{0});
    OSCTask end_dmx_i_silence      = new OSCTask(p, "/dmx/intensity", 12000, dest_ip, new Object[]{0});
    OSCTask end_dmx_d_silence      = new OSCTask(p, "/dmx/duration", 12000, dest_ip, new Object[]{0});
    OSCTask end_dmx_r_silence      = new OSCTask(p, "/dmx/rate", 12000, dest_ip, new Object[]{0});
    root.end.add_task(end_speaker_enable);
    root.end.add_task(end_ambient_silence);
    root.end.add_task(end_heart_silence);
    root.end.add_task(end_aura_silence);
    root.end.add_task(end_dmx_silence);
    root.end.add_task(end_dmx_i_silence);
    root.end.add_task(end_dmx_d_silence);
    root.end.add_task(end_dmx_r_silence);
  }

  void load_light_control_state_machine() {
    //init all variables
    light_control = new StateMachine(this.p, "light_control");
    config_1        = new State("config_1");
    config_2        = new State("config_2");
    config_3        = new State("config_3");
    light_control.add_state(config_1);
    light_control.add_state(config_2);
    light_control.add_state(config_3);

    Expression rand_equals_1  = new Expression("$light_control_stateTimer > 5 && $rand==1");
    Expression rand_equals_2  = new Expression("$light_control_stateTimer > 5 && $rand==2");
    Expression rand_equals_3  = new Expression("$light_control_stateTimer > 5 && $rand==3");
    //Expression timer_greater_than_20        = new Expression("$light_control_stateTimer > 5");
    Expression timer_greater_than_duration  = new Expression("$light_control_stateTimer > $duration");

    //SetBBTask set_duration = new SetBBTask(p, "duration", 3); //replace that by expressions
    //SetBBTask set_rand     = new SetBBTask(p, "rand", 2); //replace that by expressions
    SetBBTask set_duration = new SetBBTask(p, "duration", new Expression("math.floor(math.random()*10)")); //replace that by expressions
    SetBBTask set_rand     = new SetBBTask(p, "rand", new Expression("math.floor(math.random()*3)+1")); //replace that by expressions
    //SetBBTask set_rand     = new SetBBTask(p, "rand", new Expression("($mouseX%3)+1")); //replace that by expressions

    //adding control tasks
    light_control.begin.add_task(set_duration);
    light_control.begin.add_task(set_rand);

    //making proper connections
    light_control.begin.connect(rand_equals_1, config_1);
    light_control.begin.connect(rand_equals_2, config_2);
    light_control.begin.connect(rand_equals_3, config_3);
    config_1.connect(timer_greater_than_duration, light_control.end);
    config_2.connect(timer_greater_than_duration, light_control.end);
    config_3.connect(timer_greater_than_duration, light_control.end);
    config_1.connect(config_1);
    config_2.connect(config_2);
    config_3.connect(config_3);
    //light_control.end.connect(timer_greater_than_20, light_control.begin);
    //light_control.end.connect(light_control.end);

    //creating tasks related to config_1
    OSCTask config_1_dmx_intensity    = new OSCTask(p, "/dmx/intensity", 12000, dest_ip, new Object[]{1.});
    OSCTask config_1_dmx_duration     = new OSCTask(p, "/dmx/duration", 12000, dest_ip, new Object[]{0.1});
    OSCTask config_1_dmx_rate         = new OSCTask(p, "/dmx/rate", 12000, dest_ip, new Object[]{0.1});
    config_1.add_task(config_1_dmx_intensity);
    config_1.add_task(config_1_dmx_duration);
    config_1.add_task(config_1_dmx_rate);
    //creating tasks related to config_2
    OSCTask config_2_dmx_intensity    = new OSCTask(p, "/dmx/intensity", 12000, dest_ip, new Object[]{1.});
    OSCTask config_2_dmx_duration     = new OSCTask(p, "/dmx/duration", 12000, dest_ip, new Object[]{0.5});
    OSCTask config_2_dmx_rate         = new OSCTask(p, "/dmx/rate", 12000, dest_ip, new Object[]{0.5});
    config_2.add_task(config_2_dmx_intensity);
    config_2.add_task(config_2_dmx_duration);
    config_2.add_task(config_2_dmx_rate);
    //creating tasks related to config_3
    OSCTask config_3_dmx_intensity    = new OSCTask(p, "/dmx/intensity", 12000, dest_ip, new Object[]{0.3});
    OSCTask config_3_dmx_duration     = new OSCTask(p, "/dmx/duration", 12000, dest_ip, new Object[]{0.1});
    OSCTask config_3_dmx_rate         = new OSCTask(p, "/dmx/rate", 12000, dest_ip, new Object[]{0.1});
    config_3.add_task(config_3_dmx_intensity);
    config_3.add_task(config_3_dmx_duration);
    config_3.add_task(config_3_dmx_rate);
  }


  void draw(){
    //executes the hfsm
    root.tick();
    //and draw
    //root.draw();
    draw_proper_state_machine();
  }

  void draw_proper_state_machine() {
    switch(what_state_machine_is_showing) {
    case 0:
      sync_tester.hide();
      light_control.hide();
      root.show();
      root.draw();
      fill(255);
      //textSize(20);
      textAlign(LEFT);
      text("ROOT", 20, 20);
      break;
    case 1:
      root.hide();
      light_control.hide();
      sync_tester.show();
      sync_tester.draw();
      fill(255);
      textAlign(LEFT);
      text("ROOT > SYNC_TESTER", 20, 20);
      break;
    case 2:
      root.hide();
      sync_tester.hide();
      light_control.show();
      light_control.draw();
      fill(255);
      textAlign(LEFT);
      text("ROOT > LIGHT_CONTROL", 20, 20);
      break;
    }

    //println("number of tasks in root: " + root.begin.get_number_of_tasks());
  }

  Status get_status() {
    return root.get_status();
  }

  void reset_server() {
    OSCTask end_speaker_enable     = new OSCTask(p, "/speaker/enable", 12000, dest_ip, new Object[]{0});
    OSCTask end_ambient_silence    = new OSCTask(p, "/speaker/amp/1", 12000, dest_ip, new Object[]{0});
    OSCTask end_heart_silence      = new OSCTask(p, "/speaker/amp/0", 12000, dest_ip, new Object[]{0});
    OSCTask end_aura_silence       = new OSCTask(p, "/aura/amp/0", 12000, dest_ip, new Object[]{0});
    OSCTask end_dmx_silence        = new OSCTask(p, "/dmx/enable", 12000, dest_ip, new Object[]{0});
    OSCTask end_dmx_i_silence      = new OSCTask(p, "/dmx/intensity", 12000, dest_ip, new Object[]{0});
    OSCTask end_dmx_d_silence      = new OSCTask(p, "/dmx/duration", 12000, dest_ip, new Object[]{0});
    OSCTask end_dmx_r_silence      = new OSCTask(p, "/dmx/rate", 12000, dest_ip, new Object[]{0});

    end_speaker_enable.run();
    end_ambient_silence.run();
    end_heart_silence.run();
    end_aura_silence.run();
    end_dmx_silence.run();
    end_dmx_i_silence.run();
    end_dmx_d_silence.run();
    end_dmx_r_silence.run();
  }

  void keyPressed() {
    switch(key) {
    case ' ':
      root.run();
      break;
    case 's':
      root.stop();
      reset_server();
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

    }
  }

}
