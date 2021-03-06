

import controlP5.*;
import processing.core.PApplet;

////////////////////////////////////////
//implementing a task for OSC messages
public class StopRemoteDMXTask extends RemoteOSCTask {

  Object  channel;

  //contructor loading the file
  public StopRemoteDMXTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.message = "/dmx/stop";
    this.channel = new Expression("1");

    update_content();
  }

  //contructor loading the file
  public StopRemoteDMXTask (PApplet p, ControlP5 cp5, String id, String m, Object c, boolean r) {
	  super(p, cp5, id);
	  
	  this.message = m;
	  this.channel = c;
	  this.repeat  = r;
	  
	  update_content();
  }

  StopRemoteDMXTask clone_it () {
    return new StopRemoteDMXTask(this.p, this.cp5, this.name, this.message, this.channel, this.repeat);
  }

  void update_content () {
    this.content  = new Object[] {this.channel};
  }

  void update_channel (String uni) {
    this.channel = new Expression(uni);
    update_content();
  }


  //UI config
  Group load_gui_elements(State s) {
	  /*
    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();
    
    String textlabel = "Stop DMX";
    int font_size 	 = (int)(((ZenStates)p).get_font_size());
    int textwidth 	 = (int)((ZenStates)p).textWidth(textlabel);
    int backgroundheight = (int)(font_size* 7.5);


    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    Group g = cp5.addGroup(g_name)
    	    //.setPosition(x, y) //change that?
    	    .setHeight(font_size)
    	    .setWidth((10*((ZenStates)p).FONT_SIZE))
    	    .setBackgroundHeight(backgroundheight)
    	    .setColorBackground(p.color(255, 50)) //color of the task
    	    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    	    .setLabel(textlabel)
    	    ;


    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    int localx = 10, localy = (int)(font_size), localoffset = 3*font_size;
    int w = g.getWidth()-(localx*2);
    */
	  
	  Group g					= super.load_gui_elements(s);
	  CallbackListener cb_enter = generate_callback_enter();
	  String g_name			  	= this.get_gui_id();
	  int w 					= g.getWidth()-(localx*2);
	  
	  textlabel 	 			= "Stop DMX";
	  backgroundheight 			= (int)(font_size* 7.5);
	    
	  g.setBackgroundHeight(backgroundheight);
	  g.setLabel(textlabel);

    cp5.addTextfield(g_name+ "/channel")
      .setPosition(localx, localy)
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("channel")
      .setText(this.channel.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    create_gui_toggle(localx, localy+localoffset, w, g, cb_enter);

    return g;
  }

  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();

            if (s.equals(get_gui_id() + "/channel")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="0";
                  ((Textfield)cp5.get(get_gui_id()+ "/channel")).setText(nv);
                }
                update_channel(nv);
                //System.out.println(s + " " + nv);
            }

            check_repeat_toggle(s, theEvent);
          }
    };
  }

  void reset_gui_fields() {
    String g_name = this.get_gui_id();
    String nv;

    //if this group is not open, returns...
    if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

    nv = ((Textfield)cp5.get(g_name+"/channel")).getText();
    update_channel(nv);
  }



}
