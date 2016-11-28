////////////////////////////////////////
//implementing a task for OSC messages
class OSCTask extends Task {

  //variables to store my osc connection
  // private OscP5      oscP5;
  private NetAddress broadcast;
  //private OscMessage message;
  private Object[]  content;
  private String    message;

  //contructor loading the file
  public OSCTask (String id, String message, int port, String ip, Object[] content) {
    super(id);
    this.message   = message;
    //this.oscP5     = new OscP5(p, port+1);
    this.broadcast = new NetAddress(ip, port);
    this.content   = content;
    //this.update_message(content);
  }

  //method that returns if this OSC Task is curerntly initialized

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
    return new OSCTask(this.name, this.message, this.broadcast.port(), this.broadcast.address(), this.content);
  }

  void run () {
    this.status = Status.RUNNING;

    OscMessage msg = create_message();

    oscP5.send(msg, broadcast);

    //if (debug)
      println("sending OSC message to: " + broadcast.toString() + ". content: " + msg.toString());
    this.status = Status.DONE;
  }

  //returns a new message suited for this task
  OscMessage create_message() {

    //creates the oscmessage to be returned
    OscMessage om = new OscMessage(this.message);

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


  void update_ip (String ip) {
    this.broadcast = new NetAddress(ip, broadcast.port());
  }

  void update_port (int port) {
    this.broadcast = new NetAddress(broadcast.address(), port);
  }

  void update_message (String newMessage) {
    this.message = newMessage;
    /*
    cp5.remove(parent.name + " " + this.get_name());
    set_name(newName);
    parent.add_task_in_accordion_gui(this);
    */
  }

  String build_string_from_content () {
    //formatting strings
    String param_text = "";
    for (int i = 0; i < content.length; i++) {
      if (i!=0) param_text += ", ";
      param_text += content[i].toString();
    }

    return param_text;
  }

  void update_content_from_string (String parameters) {
    //formatting strings
    String[] split = parameters.trim().split(",");
    Object[] result = new Object[split.length];

    //iterates over all the resulting strings
    for (int i = 0; i < split.length; i++)
      result[i] = new Expression(split[i]);

    content=result;
  }

  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            String s = theEvent.getController().getName();

            if (s.equals(get_gui_id() + "/ip")) {
                String text = theEvent.getController().getValueLabel().getText();
                update_ip(text);
                println(s + " " + text);
            }
            if (s.equals(get_gui_id() + "/port")) {
                int newport = (int)theEvent.getController().getValue();
                update_port(newport);
                println(s + " " + newport);
            }
            if (s.equals(get_gui_id() + "/message")) {
                String text = theEvent.getController().getValueLabel().getText();
                update_message(text);
                println(s + " " + text);
            }

            if (s.equals(get_gui_id() + "/parameters")) {
                String text = theEvent.getController().getValueLabel().getText();
                update_content_from_string(text);
                println(s + " " + text);
            }
          }
    };
  }

  CallbackListener generate_callback_leave() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            String s = theEvent.getController().getName();

            String newtext = theEvent.getController().getValueLabel().getText();
            String oldtext = "";

            if (s.equals(get_gui_id() + "/ip"))
              oldtext = broadcast.address();
            //else if (s.equals(get_gui_id() + "/port"))
            //  oldtext = broadcast.port()+"";
            else if (s.equals(get_gui_id() + "/message"))
              oldtext = message;
            else if (s.equals(get_gui_id() + "/parameters"))
              oldtext = build_string_from_content();
            else  return;

            //if the user tried to change but did not press enter
            if (!newtext.replace(" ", "").equals(oldtext)) {
              //resets the test for the original
              Textfield t = (Textfield)cp5.get(s);
              t.setText(oldtext);
            }

          }
    };
  }

  Group load_gui_elements(State s) {
    //do we really need this?
    //this.parent = s;

    CallbackListener cb_enter = generate_callback_enter();
    CallbackListener cb_leave = generate_callback_leave();

    this.set_gui_id(s.name + " " + this.get_name());
    String g_name = this.get_gui_id();

    //creates the group
    Group g = cp5.addGroup(g_name)
      .setColorBackground(color(255, 50)) //color of the task
      .setBackgroundColor(color(255, 25)) //color of task when openned
      .setBackgroundHeight(180)
      .setLabel(this.get_prefix() + "   " + this.get_name())
      .setHeight(12)
      ;

    int w = g.getWidth()-10;

    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    int localx = 10, localy = 15, localoffset = 40;

    cp5.addTextfield(g_name+"/ip")
      .setPosition(localx, localy)
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("ip address")
      .setText(this.broadcast.address())
      .onChange(cb_enter)
      .onReleaseOutside(cb_leave)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;

    Numberbox port = cp5.addNumberbox(g_name+"/port")
      .setPosition(localx, localy+localoffset)
      .setSize(w, 15)
      .setValue(this.broadcast.port())
      .setGroup(g)
      .setLabel("port")
      .onChange(cb_enter)
      //.onReleaseOutside(cb_leave)
      ;

    port.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);

    makeEditable( port );

    cp5.addTextfield(g_name+"/message")
      .setPosition(localx, localy+(2*localoffset))
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("message")
      .setText(this.message)
      .onChange(cb_enter)
      .onReleaseOutside(cb_leave)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;



    cp5.addTextfield(g_name+"/parameters")
      .setPosition(localx, localy+(3*localoffset))
      .setSize(w, 15)
      .setAutoClear(false)
      .setGroup(g)
      .setLabel("parameters")
      .setText(build_string_from_content())
      .onChange(cb_enter)
      .onReleaseOutside(cb_leave)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;

    return g;
  }

}
