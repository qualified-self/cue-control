////////////////////////////////////////
//implementing a task for OSC messages
class OSCTask extends Task {

  //variables to store my osc connection
  // private OscP5      oscP5;
  private NetAddress broadcast;
  //private OscMessage message;
  private Object[]  content;

  //contructor loading the file
  public OSCTask (String taskname, int port, String ip, Object[] content) {
    super(taskname);
    //this.oscP5     = new OscP5(p, port+1);
    this.broadcast = new NetAddress(ip, port);
    this.content   = content;
    //this.update_message(content);
  }

  /*
  //contructor loading the file
  public OSCTask (PApplet p, String taskname, int port, String ip, Object[] content) {
    super(p, taskname);
    //this.oscP5     = new OscP5(p, port+1);
    this.broadcast = new NetAddress(ip, port);
    this.content   = content;
    //this.update_message(content);
  }
  */

  /*
  public OSCTask () {

  }
  */

  OSCTask clone() {
    return new OSCTask(this.name, this.broadcast.port(), this.broadcast.address(), this.content);
  }

  void run () {
    this.status = Status.RUNNING;

    OscMessage message = create_message();

    oscP5.send(message, broadcast);

    if (debug)
      println("sending OSC message to: " + broadcast.toString() + ". content: " + message.toString());
    this.status = Status.DONE;
  }

  //returns a new message suited for this task
  OscMessage create_message() {

    //creates the oscmessage to be returned
    OscMessage om = new OscMessage(this.name);

    //gets all the content
    Object[] args = new Object[content.length];

    //evaluates each item of the osc message
    for (int i = 0; i < args.length; i++) {
      args[i] = evaluate_value(content[i]);

      //fixes the problems for in sending double in osc messages
      if (args[i] instanceof Double)
        args[i] = ((Double)args[i]).floatValue();
    }

    //clearing the arguements and adding the new values
    om.add(args);

    return om;
  }

  void stop() {
    //Object[] args = message.arguments();
    //message.clear();
    //update_message(args);
    this.status = Status.INACTIVE;
  }

  void update_message (Object[] content) {
    //this.message.clearArguments();

    //updates the evaluated objects to the osc message
    this.content = content;
  }

  //in this case, nothing is done
  void update_status() {
  }

}
