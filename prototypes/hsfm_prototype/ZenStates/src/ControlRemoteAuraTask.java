


import controlP5.*;
import processing.core.PApplet;


////////////////////////////////////////
//implementing a task for OSC messages
public class ControlRemoteAuraTask extends RemoteOSCTask {

  Object  intensity;
  Object  pan;

  //contructor loading the file
  public ControlRemoteAuraTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.message = "/aura/control";
    this.intensity = new Expression("0.0");
    this.pan      = new Expression("0.5");

    update_content();
  }

  //contructor loading the file
  public ControlRemoteAuraTask (PApplet p, ControlP5 cp5, String id, String m, Object i, Object pan, boolean repeat) {
	  super(p, cp5, id);
	  
	  this.message 	 = m;
	  this.intensity = i;
	  this.pan       = pan;
	  this.repeat    = repeat; 
	  
	  update_content();
  }

  ControlRemoteAuraTask clone_it () {
    return new ControlRemoteAuraTask(this.p, this.cp5, this.name, this.message, this.intensity, this.pan, this.repeat);
  }

  void update_content () {
    this.content  = new Object[] {this.intensity, this.pan};
  }

  void update_intensity(String inten) {
    this.intensity = new Expression(inten);
    update_content();
  }
  

  void update_pan(String pn) {
    this.pan = new Expression(pn);
    update_content ();
  }


  //UI config
  Group load_gui_elements(State s) {

	 /*
    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();

    String textlabel = "Control aura";
    int font_size 	 = (int)(((ZenStates)p).get_font_size());
    int textwidth 	 = (int)((ZenStates)p).textWidth(textlabel);
    int backgroundheight = (int)(font_size* 10.5);

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
    */
	  
	  Group g					= super.load_gui_elements(s);
	  CallbackListener cb_enter = generate_callback_enter();
	  String g_name			  	= this.get_gui_id();
	  int w 					= g.getWidth()-(localx*2);
	  
	  textlabel 	 			= "Control aura";
	  backgroundheight 			= (int)(font_size* 10.5);
	    
	  g.setBackgroundHeight(backgroundheight);
	  g.setLabel(textlabel);


    cp5.addTextfield(g_name+ "/intensity")
      .setPosition(localx, localy)
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("intensity")
      .setText(this.intensity.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;
    
    cp5.addTextfield(g_name+ "/pan")
    .setPosition(localx, localy+localoffset)
    .setSize(w, (int)(font_size*1.25))
    .setGroup(g)
    .setAutoClear(false)
    .setLabel("pan")
    .setText(this.pan+"")
    .onChange(cb_enter)
    .onReleaseOutside(cb_enter)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    ;

    create_gui_toggle(localx, localy+(2*localoffset), w, g, cb_enter);

    return g;
  }

  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();
            //p.println("qu'est-ce que y a la? " + s);

            if (s.equals(get_gui_id() + "/intensity")) {
                String nv = theEvent.getController().getValueLabel().getText();

                if (nv.trim().equals("")) {
                  nv="0.0";
                  ((Textfield)cp5.get(get_gui_id()+ "/intensity")).setText(nv);
                }
                update_intensity(nv);
                //System.out.println(s + " " + nv);
            }
            
            if (s.equals(get_gui_id() + "/pan")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="0.0";
                  ((Textfield)cp5.get(get_gui_id()+ "/pan")).setText(nv);
                }
                update_pan(nv);

            }

            check_repeat_toggle(s, theEvent);
          }
    };
  }

  CallbackListener test() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {
            reset_gui_fields();
          }
    };
  }

  void reset_gui_fields() {
    String g_name = this.get_gui_id();
    String nv;

    if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

    nv = ((Textfield)cp5.get(g_name+"/intensity")).getText();

    if (nv.trim().equals("")) {
      nv="0.0";
      ((Textfield)cp5.get(get_gui_id()+ "/intensity")).setText(nv);
    }
    
    nv = ((Textfield)cp5.get(g_name+"/pan")).getText();
    update_pan(nv);

    update_intensity(nv);
  }




}
