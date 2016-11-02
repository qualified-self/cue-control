/************************************************ //<>// //<>// //<>// //<>//
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

  public Task (String taskname) {
    this.name   = taskname.toUpperCase();
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

  String get_prefix() {
    String result = "[TASK]";

    if (this instanceof SetBBTask) result = "[B_B]";
    if (this instanceof AudioTask) result = "[AUDIO]";
    if (this instanceof OSCTask) result = "[OSC]";
    if (this instanceof State_Machine) result = "[S_M]";

    //create other according to the type of the task

    return result;
  }

  abstract void run();
  abstract void update_status();
  abstract void stop();
}

////////////////////////////////////////
//implementing a task for audio
class AudioTask extends Task {

  //audio variables
  private Minim       minim;
  private AudioPlayer soundfile;

  //contructor loading the file
  public AudioTask (PApplet p, String taskname, String filename) {
    super(taskname);
    this.minim     = new Minim(p);
    this.soundfile = minim.loadFile(filename);
  }

  //implementing the execute method (play the music)
  void run () {
    soundfile.play();
    println("Task " + this + " playing!");
    this.status = Status.RUNNING;
  }

  void stop() {
    soundfile.pause();
    soundfile.rewind();
    this.status = Status.INACTIVE;
  }

  void update_status() {
    boolean playing = soundfile.isPlaying();

    if (playing)
      this.status = Status.RUNNING;
    else
      this.status = Status.DONE;
  }
} 


////////////////////////////////////////
//implementing a task for setting the blackboard
class SetBBTask extends Task {

  Object value;

  public SetBBTask (PApplet p, String taskname, Object value) {
    super(taskname);
    this.value = value;
  }

  //function that tries to evaluates the value (if necessary) and returns the real value
  Object evaluate_value () {
    Object ret = value;

    // If added an expression, process it and save result in blackboard.
    if (value instanceof Expression)
    {
      try {
        ret = ((Expression)value).eval(bb);
      } 
      catch (ScriptException e) {
        println("ScriptExpression thrown, unhandled update.");
      }
    }

    return ret;
  }

  void run() {
    this.status = Status.RUNNING;

    bb.put(name, evaluate_value());

    this.status = Status.DONE;
  }

  void stop() {
    this.status = Status.INACTIVE;
  }

  void update_value(Object new_value) {
    value = new_value;
  }

  void update_status() {
  }
}


////////////////////////////////////////
//implementing a task for OSC messages
class OSCTask extends Task {

  //variables to store my osc connection
  // private OscP5      oscP5;
  private NetAddress broadcast;
  private OscMessage message;

  //contructor loading the file
  public OSCTask (PApplet p, String taskname, int port, String ip, Object[] content) {
    super(taskname);
    //this.oscP5     = new OscP5(p, port+1);
    this.broadcast = new NetAddress(ip, port);
    this.update_message(content);
  }

  void run () {
    this.status = Status.RUNNING;
    oscP5.send(message, broadcast);
    println("sending OSC message to: " + broadcast.toString() + ". content: " + message.toString());
    this.status = Status.DONE;
  }

  void stop() {
    Object[] args = message.arguments();
    message.clear();
    update_message(args);
    this.status = Status.INACTIVE;
  }

  void update_message (Object[] content) {
    this.message = new OscMessage(this.name.toLowerCase());
    this.message.add(content);
  }

  //in this case, nothing is done
  void update_status() {
  }
}