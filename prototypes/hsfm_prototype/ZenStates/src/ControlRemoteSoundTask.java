


import controlP5.*;
import processing.core.PApplet;


////////////////////////////////////////
//implementing a task for OSC messages
public class ControlRemoteSoundTask extends RemoteOSCTask {

  String filename;
  int sample_choice;
  Object  volume;
  Object  pan;

  //constructor loading the file
  public ControlRemoteSoundTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.message  = "/speaker/control";
    this.filename = "example.wav";
    this.volume   = new Expression("0.0");
    this.pan      = new Expression("0.5");
    this.sample_choice = 0;
    //adding the sample_choice inside the address
    this.message = this.message + "/" + this.sample_choice;

    update_content();
  }

  //constructor loading the file
  public ControlRemoteSoundTask (PApplet p, ControlP5 cp5, String id, String m, String f, Object v, Object pan, int s, boolean repeat) {
	  super(p, cp5, id);
	  
	  this.message  = m;
	  this.filename = f;
	  this.volume   = v;
	  this.pan      = pan;
	  this.sample_choice = s;
	  //adding the sample_choice inside the address
	  this.message = this.message + "/" + this.sample_choice;
	  this.repeat = repeat;
	  
	  update_content();
  }

  ControlRemoteSoundTask clone_it () {
    return new ControlRemoteSoundTask(this.p, this.cp5, this.name, this.message, this.filename, this.volume, this.pan, this.sample_choice, this.repeat);
  }
  
  /*
  void update_name(String name) {
    this.filename = name;
    update_content();
  }
  */
  
  //adding the sample_choice inside the address
  void combine_message_and_sample() {
	  String temp = message.substring(0, message.length()-1);
	  this.message = temp + this.sample_choice;
  }
  
  //updates the sample_choice and the message content accordingly
  void update_sample(int new_sample) {
	  sample_choice = new_sample;
	  combine_message_and_sample();
	  update_content();
  }

  void update_volume(String vol) {
    this.volume = new Expression(vol);
    update_content ();
  }

  void update_pan(String pn) {
    this.pan = new Expression(pn);
    update_content ();
  }

  void update_content () {
    //this.content  = new Object[] {this.filename, this.volume, this.pan};
    //this.content  = new Object[] {this.sample_choice, this.volume, this.pan};
	  this.content  = new Object[] {this.volume, this.pan};
  }


  //UI config
  Group load_gui_elements(State s) {

    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    //p.println("name: " + this.get_gui_id() + " task: " + this.getClass());
    String g_name = this.get_gui_id();

    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    Group g = cp5.addGroup(g_name)
    //.setPosition(x, y) //change that?
    .setHeight(12)
    .setBackgroundHeight(230)
    .setColorBackground(p.color(255, 50)) //color of the task
    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    .setLabel("Control audio")
    ;

    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    int localx = 10, localy = 15, localoffset = 40;
    int w = g.getWidth()-10;

    /*
    cp5.addTextfield(g_name+ "/filename")
      .setPosition(localx, localy)
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("filename")
      .setText(this.filename)
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;
    */

    cp5.addTextfield(g_name+ "/volume")
      .setPosition(localx, localy)
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("volume")
      .setText(this.volume+"")
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;

      cp5.addTextfield(g_name+ "/pan")
        .setPosition(localx, localy+(1*localoffset))
        .setSize(w, 15)
        .setGroup(g)
        .setAutoClear(false)
        .setLabel("pan")
        .setText(this.pan+"")
        .onChange(cb_enter)
        .onReleaseOutside(cb_enter)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
        ;

    create_gui_toggle(localx, localy+(2*localoffset), w, g, cb_enter);
    
    cp5.addDropdownList(g_name+ "/sample")
    .setPosition(localx, localy+(3*localoffset))
    .setSize(w, 150)
    .setGroup(g)
    .setLabel("sample")
    .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
    .setItemHeight(20)
    .setBarHeight(15)
    .close()
    .onChange(cb_enter)
    //.onReleaseOutside(cb_enter)
    .addItem("Sample 1", 0)
    .addItem("Sample 2", 1)
    .addItem("Sample 3", 2)
    .addItem("Sample 4", 3)
    .setDefaultValue(this.sample_choice)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    return g;
  }


  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();

            /*
            if (s.equals(get_gui_id() + "/filename")) {
                String nv = theEvent.getController().getValueLabel().getText();

                //if the filename is empty, resets
                if (nv.trim().equalsIgnoreCase("")) {
                  ((Textfield)cp5.get(get_gui_id() + "/filename")).setText(filename);
                  return;
                }

                update_name(nv);
                System.out.println(s + " " + nv);
            }*/
            
            if (s.equals(get_gui_id() + "/sample")) 
            	update_sample((int)theEvent.getController().getValue());

            if (s.equals(get_gui_id() + "/volume")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="0.0";
                  ((Textfield)cp5.get(get_gui_id()+ "/volume")).setText(nv);
                }
                update_volume(nv);
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

  void reset_gui_fields() {
    String g_name = this.get_gui_id();
    String nv;

    //if this group is not open, returns...
    if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

    //nv = ((Textfield)cp5.get(g_name+"/filename")).getText();
    //update_name(nv);
    nv = ((Textfield)cp5.get(g_name+"/volume")).getText();
    update_volume(nv);
    nv = ((Textfield)cp5.get(g_name+"/pan")).getText();
    update_pan(nv);

  }


}
