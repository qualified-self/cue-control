

import java.io.Serializable;
import processing.core.PApplet;
import controlP5.*;
import javax.script.*;

import java.util.UUID;

////////////////////////////////////////
//this is the abstract class every task needs to implement
public abstract class Task implements Serializable {
  protected Status status;
  protected String name; //@TODO THIS SHOULD BE AN ID INSTEAD!!!
  protected String group_gui_id;
  protected boolean repeat;
  protected boolean first_time;
  //protected State  parent;
  transient protected PApplet  p;
  transient protected ControlP5 cp5;


  public Task (PApplet p, ControlP5 cp5, String taskname) {
    this.p = p;
    this.cp5 = cp5;
    this.name   = taskname;
    this.repeat = true;
    this.status = Status.INACTIVE;
    this.group_gui_id = UUID.randomUUID().toString();
    first_time = true;

    System.out.println("task " + this.toString() + " created!");
  }
  /*
  public Task (PApplet p, String taskname) {
    //this.p = p;
    this.name   = taskname;
    this.status = Status.INACTIVE;

    println("task " + this.toString() + " created!");
  }
  */

  void set_name(String newname) {
    this.name = newname;
  }

  String get_name() {
    return this.name;
  }

  String get_gui_id() {
    return this.group_gui_id;
  }

  /*
  //method that generates a random name for the demo task
  String generate_random_group_id(State s) {
    this.group_gui_id = ("/" + s.get_name() + "/"+ this.getClass() + "/"+ ((int)p.random(-100, 100)));
    return this.group_gui_id;
  }

  String get_gui_id() {
    return this.group_gui_id;
  }

  void set_gui_id(String g_name) {
    this.group_gui_id = g_name;
  }
  */


  Status get_status () {
    return this.status;
  }

  void refresh() {
    this.stop();
  }

  void reset_first_time() {
    this.first_time = true;
  }

  void interrupt() {
    this.stop();
    this.reset_first_time();
    this.status = Status.DONE;
  }

  String get_prefix() {
    String result = "[TASK]";

    if (this instanceof SetBBTask) result = "[B_B]";
    if (this instanceof AudioTask) result = "[AUDIO]";
    if (this instanceof OSCTask) result = "[OSC]";
    if (this instanceof StateMachine) result = "[S_M]";

    //create other according to the type of the task

    return result;
  }

  //function that tries to evaluates the value (if necessary) and returns the real value
  Object evaluate_value (Object o) {
    Object ret = o;
    Blackboard board = ZenStates.instance().board();

    // If added an expression, process it and save result in blackboard.
    if (o instanceof Expression) {
      try {
        ret = ((Expression)o).eval(board);
      }
      catch (ScriptException e) {
        System.out.println("ScriptExpression thrown, unhandled update.");
      }
    }

    return ret;
  }

  //check if this task should be executed repeatedly or only once
  boolean should_run () {

    boolean result = true;
    //checkes if this should be executed only once
    if (!repeat) {
      //if this is the first time, go on
      if (first_time) first_time = false;
      //if it's not the first time, do not execute anything
      else result = false;
    }

    return result;
  }

  void stop () {

  }
  //these method should be reimplemented
  abstract void run();
  abstract void build(PApplet p, ControlP5 cp5);
  abstract void update_status();
  //abstract void stop();
  abstract Task clone_it();


  //////////////////////////////
  //gui commands
  void check_repeat_toggle(String s, CallbackEvent theEvent) {
    if (s.equals(get_gui_id() + "/repeat")) {
        float value = theEvent.getController().getValue();
        if (value==0.0)  {
          this.repeat = false; //once
          this.first_time = true;
        } else             this.repeat = true;  //repeat
    }
  }

  void create_gui_toggle (int x, int y, int w, Group g, CallbackListener cb) {
    // create a toggle
    cp5.addToggle(get_gui_id()+"/repeat")
       .setPosition(x, y)
       .setSize(w, 15)
       .setGroup(g)
       .setMode(ControlP5.SWITCH)
       .setLabel("repeat           once")
       .setValue(this.repeat)
       .onChange(cb)
       .onReleaseOutside(cb)
       .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
       ;
  }

  //abstract CallbackListener generate_callback_leave(){}
  abstract CallbackListener generate_callback_enter();
  abstract Group load_gui_elements(State s);
  abstract void reset_gui_fields();
  //abstract void draw_gui();
}
