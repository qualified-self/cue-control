
import oscP5.*;
import netP5.*;
import controlP5.*;
import processing.core.PApplet;

////////////////////////////////////////
//implementing a task for OSC messages
class OSCTask extends Task {

  //variables to store my osc connection
  // private OscP5      oscP5;
  //transient private NetAddress broadcast;
  //private OscMessage message;
  private Object[]  content;
  private String    message;
  private String    ip;
  private int       port;
  transient private NetAddress broadcast;
  transient private OscP5      oscP5;

  //contructor loading the file
  public OSCTask (PApplet p, ControlP5 cp5, String id, String message, int port, String ip, Object[] content) {
    super(p, cp5, id);
    this.message   = message;
    this.ip        = ip;
    this.port      = port;
    //this.oscP5     = new OscP5(p, port+1);
    //this.broadcast = new NetAddress(ip, port);
    this.content   = content;
    //this.broadcast = null;
    //this.update_message(content);
    this.build(p, cp5);
  }
  
  //contructor loading the file
  public OSCTask (PApplet p, ControlP5 cp5, String id, String message, int port, String ip, Object[] content, boolean repeat) {
    this(p, cp5, id, message, port, ip, content);
    this.repeat = repeat;
  }

  void build(PApplet p, ControlP5 cp5) {
    this.p = p;
    this.cp5 = cp5;
    this.broadcast = new NetAddress(ip, port);
    //this.oscP5     = new OscP5(p, port+1);
    this.oscP5 = ZenStates.instance().oscP5();
  }

  //method that returns if this OSC Task is curerntly initialized
  OSCTask clone_it() {
    return new OSCTask(this.p, this.cp5, this.name, this.message, this.port, this.ip, this.content, this.repeat);
  }

  void run () {
    if (!should_run()) return;

    this.status = Status.RUNNING;

    OscMessage msg = create_message();

    //if (broadcast==null)
    //NetAddress broadcast = new NetAddress(ip, port);
    //OscP5 oscP5 = HFSMPrototype.instance().oscP5();

    oscP5.send(msg, broadcast);

    if (((ZenStates)p).debug)
    	System.out.println("sending OSC message to: " + broadcast.toString() + ". content: " + msg.toString());
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
    super.stop();
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
    this.ip = ip;
    this.broadcast = new NetAddress(ip, port);
  }

  void update_port (String port) {
	  int v = Integer.parseInt(port);
	  update_port(v);
  }
  
  void update_port (int port) {
    this.port = port;
    this.broadcast = new NetAddress(ip, port);
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

  Group load_gui_elements(State s) {
    //do we really need this?
    //this.parent = s;
    //PApplet p = HFSMPrototype.instance();
    //ControlP5 cp5 = HFSMPrototype.instance().cp5();
    int c1 = p.color(255, 50);
    int c2 = p.color(255, 25);

    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();
    
    String textlabel = "OSC message";
    int font_size 	 = (int)(((ZenStates)p).get_font_size());
    int textwidth 	 = (int)((ZenStates)p).textWidth(textlabel);
    int backgroundheight = (int)(font_size* 16.5);

    Group g = cp5.addGroup(g_name)
    	    //.setPosition(x, y) //change that?
    	    .setHeight(font_size)
    	    .setBackgroundHeight(backgroundheight)
    	    .setColorBackground(p.color(255, 50)) //color of the task
    	    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    	    .setLabel(textlabel)
    	    ;
    

    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    int localx = 10, localy = (int)(font_size), localoffset = 3*font_size;
    int w = g.getWidth()-10;

    cp5.addTextfield(g_name+"/ip")
      .setPosition(localx, localy)
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("ip address")
      .setText(ip)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;

    /*
    Numberbox port_gui = cp5.addNumberbox(g_name+"/port")
      .setPosition(localx, localy+localoffset)
      .setSize(w, 15)
      .setValue(port)
      .setGroup(g)
      .setLabel("port")
      .onChange(cb_enter)
      //.onReleaseOutside(cb_leave)
      ;

    port_gui.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);

    ZenStates.instance().makeEditable( port_gui );
    */
    
	cp5.addTextfield(g_name+"/port")
	  .setPosition(localx, localy+localoffset)
	  .setSize(w, (int)(font_size*1.25))
	  .setGroup(g)
	  .setAutoClear(false)
	  .setLabel("port")
	  .setText(Integer.toString(port))
	  .onChange(cb_enter)
	  .onReleaseOutside(cb_enter)
	  .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
	  ;
      

    cp5.addTextfield(g_name+"/message")
      .setPosition(localx, localy+(2*localoffset))
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("message")
      .setText(this.message)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;

    cp5.addTextfield(g_name+"/parameters")
      .setPosition(localx, localy+(3*localoffset))
      .setSize(w, (int)(font_size*1.25))
      .setAutoClear(false)
      .setGroup(g)
      .setLabel("parameters")
      .setText(build_string_from_content())
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;

    create_gui_toggle(localx, localy+(4*localoffset), w, g, cb_enter);

    return g;
  }

  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();

            if (s.equals(get_gui_id() + "/ip")) {
                String text = theEvent.getController().getValueLabel().getText();
                //if text is empty, resets
                if (text.trim().equalsIgnoreCase("")) {
                  ((Textfield)cp5.get(get_gui_id() + "/ip")).setText(ip);
                  return;
                }
                update_ip(text);
                //System.out.println(s + " " + text);
            }
            /*
            if (s.equals(get_gui_id() + "/port")) {
                int newport = (int)theEvent.getController().getValue();
                update_port(newport);
                //System.out.println(s + " " + newport);
            }*/
            
            if (s.equals(get_gui_id() + "/port")) {
                String text = theEvent.getController().getValueLabel().getText();
                //if text is empty, resets
                if (text.trim().equalsIgnoreCase("")) {
                  ((Textfield)cp5.get(get_gui_id() + "/port")).setText(Integer.toString(port));
                  return;
                }
                update_port(text);
                //System.out.println(s + " " + text);
            }
            
            
            if (s.equals(get_gui_id() + "/message")) {
                String text = theEvent.getController().getValueLabel().getText();
                //if text is empty, resets
                if (text.trim().equalsIgnoreCase("")) {
                  ((Textfield)cp5.get(get_gui_id() + "/message")).setText(message);
                  return;
                }
                update_message(text);
                //System.out.println(s + " " + text);
            }

            if (s.equals(get_gui_id() + "/parameters")) {
                String text = theEvent.getController().getValueLabel().getText();
                //if text is empty, resets
                if (text.trim().equalsIgnoreCase("")) {
                  ((Textfield)cp5.get(get_gui_id() + "/parameters")).setText(build_string_from_content());
                  return;
                }
                update_content_from_string(text);
                //System.out.println(s + " " + text);
            }

            check_repeat_toggle(s, theEvent);
          }


    };
  }

  /*
  CallbackListener generate_callback_leave() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();

            String newtext = theEvent.getController().getValueLabel().getText();
            String oldtext = "";

            if (s.equals(get_gui_id() + "/ip"))
              oldtext = ip;
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
              //ControlP5 cp5 = HFSMPrototype.instance().cp5();
              Textfield t = (Textfield)cp5.get(s);
              t.setText(oldtext);
            }

          }
    };

  }
  */


  void reset_gui_fields() {
    String g_name = this.get_gui_id();
    String nv;

    //if this group is not open, returns...
    if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

    nv = ((Textfield)cp5.get(g_name+"/ip")).getText();
    update_ip(nv);
    nv = ((Textfield)cp5.get(g_name+"/port")).getText();
    update_port(nv);
    nv = ((Textfield)cp5.get(g_name+"/message")).getText();
    update_message(nv);
    nv = ((Textfield)cp5.get(g_name+"/parameters")).getText();
    update_content_from_string(nv);

  }


}
