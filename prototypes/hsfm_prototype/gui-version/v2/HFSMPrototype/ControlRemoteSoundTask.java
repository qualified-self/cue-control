/************************************************
 ** Control Remote Sound Task ********************
 ************************************************
 ** Control audio on the multimedia server via via OSC messages
 ************************************************
 ** jeraman.info, Jan 12 2016 ******************
 ************************************************
 ************************************************/


import controlP5.*;
import processing.core.PApplet;


////////////////////////////////////////
//implementing a task for OSC messages
public class ControlRemoteSoundTask extends RemoteOSCTask {

  String filename;
  Object  volume;
  Object  pan;

  //contructor loading the file
  public ControlRemoteSoundTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.message  = "/speaker/control";
    this.filename = "example.wav";
    this.volume   = new Expression("0.0");
    this.pan      = new Expression("0.5");

    update_content();
    //this.content  = new Object[] {this.filename, this.volume, this.pan};

    //this.build(p, cp5);
  }

  ControlRemoteSoundTask clone_it () {
    return new ControlRemoteSoundTask(this.p, this.cp5, this.name);
  }

  void update_name(String name) {
    this.filename = name;
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
    this.content  = new Object[] {this.filename, this.volume, this.pan};
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
    .setBackgroundHeight(180)
    .setColorBackground(p.color(255, 50)) //color of the task
    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    .setLabel("Control audio")
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

    cp5.addTextfield(g_name+ "/volume")
      .setPosition(localx, localy+localoffset)
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
        .setPosition(localx, localy+(2*localoffset))
        .setSize(w, 15)
        .setGroup(g)
        .setAutoClear(false)
        .setLabel("pan")
        .setText(this.pan+"")
        .onChange(cb_enter)
        .onReleaseOutside(cb_enter)
        .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
        ;

    create_gui_toggle(localx, localy+(3*localoffset), w, g, cb_enter);

    return g;
  }


  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();

            if (s.equals(get_gui_id() + "/filename")) {
                String nv = theEvent.getController().getValueLabel().getText();

                //if the filename is empty, resets
                if (nv.trim().equalsIgnoreCase("")) {
                  ((Textfield)cp5.get(get_gui_id() + "/filename")).setText(filename);
                  return;
                }

                update_name(nv);
                System.out.println(s + " " + nv);
            }

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

    nv = ((Textfield)cp5.get(g_name+"/filename")).getText();
    update_name(nv);
    nv = ((Textfield)cp5.get(g_name+"/volume")).getText();
    update_volume(nv);
    nv = ((Textfield)cp5.get(g_name+"/pan")).getText();
    update_pan(nv);

  }


}
