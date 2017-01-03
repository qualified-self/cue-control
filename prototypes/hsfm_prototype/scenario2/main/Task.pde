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

////////////////////////////////////////
//this is the abstract class every task needs to implement
public abstract class Task {
  protected Status status;
  protected String name;
  protected PApplet  p;

  public Task (PApplet p, String taskname) {
    this.p = p;
    this.name   = taskname;
    this.status = Status.INACTIVE;

    println("task " + this.toString() + " created!");
  }

  void set_name(String newname) {
    this.name = newname;
  }

  String get_name() {
    return this.name;
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

    // If added an expression, process it and save result in blackboard.
    if (o instanceof Expression) {
      try {
        ret = ((Expression)o).eval(bb);
      }
      catch (ScriptException e) {
        println("ScriptExpression thrown, unhandled update.");
      }
    }

    return ret;
  }

  abstract void run();
  abstract void update_status();
  abstract void stop();
  abstract Task clone();
}
