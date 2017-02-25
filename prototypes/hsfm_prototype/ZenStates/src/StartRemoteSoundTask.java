

import oscP5.*;
import netP5.*;
import controlP5.*;
import processing.core.PApplet;

////////////////////////////////////////
//implementing a task for OSC messages
public class StartRemoteSoundTask extends RemoteOSCTask {

  String filename;

  //contructor loading the file
  public StartRemoteSoundTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.message = "/speaker/start";
    this.filename = "example.wav";

    update_content();
    //this.content = new Object[] {filename};

    //this.build(p, cp5);
  }

  StartRemoteSoundTask clone_it () {
    return new StartRemoteSoundTask(this.p, this.cp5, this.name);
  }

  void update_name(String name) {
    this.filename = name;
    update_content();
  }

  void update_content () {
    this.content = new Object[] {filename};
  }

  //UI config
  Group load_gui_elements(State s) {

    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //p.println(generate_random_group_id(s));
    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();

    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    Group g = cp5.addGroup(g_name)
    //.setPosition(x, y) //change that?
    .setHeight(12)
    .setBackgroundHeight(50)
    .setColorBackground(p.color(255, 50)) //color of the task
    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    .setLabel("Start audio")
    ;

    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    int localx = 10, localy = 15, localoffset = 40;
    int w = g.getWidth()-10;

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

    create_gui_toggle(localx, localy+localoffset, w, g, cb_enter);

    return g;
  }


  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();

            if (s.equals(get_gui_id() + "/filename")) {
                String newFilename = theEvent.getController().getValueLabel().getText();

                //if the filename is empty, resets
                if (newFilename.trim().equalsIgnoreCase("")) {
                  ((Textfield)cp5.get(get_gui_id() + "/filename")).setText(filename);
                  return;
                }

                update_name(newFilename);
                System.out.println(s + " - " + newFilename);
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

    nv = ((Textfield)cp5.get(g_name+"/filename")).getText();
    update_name(nv);

  }
  
  /*
  void draw_gui() {
	  String g_name = this.get_gui_id();
	  cp5.get(g_name).draw(p.g);
	  cp5.get(g_name+ "/filename").draw(p.g); 
	  cp5.get(g_name+"/repeat").draw(p.g);
  }
  */

}
