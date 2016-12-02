/************************************************
 ** Abstract Task class and all possible kids (audio, osc, etc)
 ************************************************
 ** MISSING: ************************************
 **  - DMX: http://motscousus.com/stuff/2011-01_dmxP512/
 **  - MIDI: The MIDI Bus (Tools > Add Tool) ****
 **  - Blackboard *******************************
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

import java.io.Serializable;
import processing.core.PApplet;
import controlP5.*;
import javax.script.*;

////////////////////////////////////////
//this is the abstract class every task needs to implement
public abstract class Task implements Serializable {
  protected Status status;
  protected String name; //@TODO THIS SHOULD BE AN ID INSTEAD!!!
  protected String group_gui_id;
  //protected State  parent;
  transient protected PApplet  p;

  public Task (PApplet p, String taskname) {
    this.p = p;
    this.name   = taskname;
    this.status = Status.INACTIVE;

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

  void set_gui_id(String g_name) {
    this.group_gui_id = g_name;
  }

  Status get_status () {
    return this.status;
  }

  void refresh() {
    this.stop();
  }

  void interrupt() {
    this.stop();
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
    Blackboard board = HFSMPrototype.instance().board();

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

  abstract void run();
  abstract void build(PApplet p);
  abstract void update_status();
  abstract void stop();
  abstract Task clone_it();
  //abstract CallbackListener generate_callback_leave(){}
  //abstract CallbackListener generate_callback_enter(){}
  //Group load_gui_elements(State s) { return null; }
  abstract Group load_gui_elements(State s);
}
