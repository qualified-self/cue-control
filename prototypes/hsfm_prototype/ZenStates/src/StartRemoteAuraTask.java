

import controlP5.*;
import processing.core.PApplet;

////////////////////////////////////////
//implementing a task for OSC messages
public class StartRemoteAuraTask extends RemoteOSCTask {

  //contructor loading the file
  public StartRemoteAuraTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.content = new Object[] {};
    this.message = "/aura/start";

    //this.build(p, cp5);
  }
  
//contructor loading the file
  public StartRemoteAuraTask (PApplet p, ControlP5 cp5, String id, String message, Object [] content, boolean r) {
	super(p, cp5, id);
	
    this.content = content;
    this.message = message;
    this.repeat  = r;

    //this.build(p, cp5);
  }

  StartRemoteAuraTask clone_it () {
    return new StartRemoteAuraTask(this.p, this.cp5, this.name, this.message, this.content, this.repeat);
  }


  //UI config
  Group load_gui_elements(State s) {

	  /*
    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //p.println(generate_random_group_id(s));
    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();
    
    String textlabel = "Start aura";
    int font_size 	 = (int)(((ZenStates)p).get_font_size());
    int textwidth 	 = (int)((ZenStates)p).textWidth(textlabel);
    int backgroundheight = (int)(font_size* 5);

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

    int localx = 10, localy = 15, localoffset = 40;
    int w = g.getWidth()-(localx*2);
    */
	  
	  Group g					= super.load_gui_elements(s);
	  CallbackListener cb_enter = generate_callback_enter();
	  String g_name			  	= this.get_gui_id();
	  int w 					= g.getWidth()-(localx*2);
	  
	  textlabel 	 			= "Start aura";
	  backgroundheight 			= (int)(font_size* 4);
	    
	  g.setBackgroundHeight(backgroundheight);
	  g.setLabel(textlabel);

    create_gui_toggle(localx, localy, w, g, cb_enter);

    return g;
  }


  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();
            check_repeat_toggle(s, theEvent);
          }
    };
  }

  void reset_gui_fields() {
    String g_name = this.get_gui_id();
    String nv;

    //if this group is not open, returns...
    if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

    //nothing in here!
  }




}
