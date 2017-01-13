/************************************************
 ** Control Remote Haptics Task ********************
 ************************************************
 ** Control hatics on the multimedia server via via OSC messages
 ************************************************
 ** jeraman.info, Jan 12 2016 ******************
 ************************************************
 ************************************************/


import controlP5.*;
import processing.core.PApplet;


////////////////////////////////////////
//implementing a task for OSC messages
public class ControlRemoteAuraTask extends RemoteOSCTask {

  Object  intensity;

  //contructor loading the file
  public ControlRemoteAuraTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.message = "/aura/amp/0";
    this.intensity = new Expression("0.0");

    update_content();

    //this.build(p, cp5);
  }

  ControlRemoteAuraTask clone_it () {
    return new ControlRemoteAuraTask(this.p, this.cp5, this.name);
  }

  void update_content () {
    this.content  = new Object[] {this.intensity};
  }

  void update_intensity(String inten) {
    this.intensity = new Expression(inten);
    update_content();
  }


  //UI config
  Group load_gui_elements(State s) {

    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();

    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    Group g = cp5.addGroup(g_name)
    //.setPosition(x, y) //change that?
    .setHeight(12)
    .setBackgroundHeight(50)
    .setColorBackground(p.color(255, 50)) //color of the task
    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    .setLabel("Control haptics")
    ;

    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    int localx = 10, localy = 15, localoffset = 40;
    int w = g.getWidth()-10;

    cp5.addTextfield(g_name+ "/filename")
      .setPosition(localx, localy)
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("intensity")
      .setText(this.intensity.toString())
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

            String s = theEvent.getController().getName();

            if (s.equals(get_gui_id() + "/intensity")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="0.0";
                  ((Textfield)cp5.get(get_gui_id()+ "/intensity")).setText(nv);
                }
                update_intensity(nv);
                //System.out.println(s + " " + nv);
            }

            check_repeat_toggle(s, theEvent);
          }
    };
  }




}
