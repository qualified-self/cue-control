/************************************************
 ** Control Remote DMX Task ********************
 ************************************************
 ** Control DMX on the multimedia server via via OSC messages
 ************************************************
 ** jeraman.info, Jan 12 2016 ******************
 ************************************************
 ************************************************/


import controlP5.*;
import processing.core.PApplet;


////////////////////////////////////////
//implementing a task for OSC messages
public class ControlRemoteDMXTask extends RemoteOSCTask {

  //contructor loading the file
  public ControlRemoteDMXTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.content = new Object[] {0};
    this.message = "/dmx/enable";

    //this.build(p, cp5);
  }

  ControlRemoteDMXTask clone_it () {
    return new ControlRemoteDMXTask(this.p, this.cp5, this.name);
  }


  //UI config
  Group load_gui_elements(State s) {

    //CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();

    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    Group g = cp5.addGroup(g_name)
    //.setPosition(x, y) //change that?
    .setHeight(12)
    .setBackgroundHeight(50)
    .setColorBackground(p.color(255, 50)) //color of the task
    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    .setLabel("Control DMX")
    ;


    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    /*
    int localx = 10, localy = 15, localoffset = 40;
    int w = g.getWidth()-10;

    cp5.addTextfield(g_name+ "/filename")
      .setPosition(localx, localy)
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("filename")
      .setText(this.filename)
      .onChange(cb_enter)
      .onReleaseOutside(cb_leave)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    /*
    // add a vertical slider
    cp5.addSlider(g_name+ "/volume")
      .setPosition(localx, localy+localoffset)
      .setSize(w, 15)
      .setRange(0, 1)
      .setGroup(g)
      .setValue(1)
      .setLabel("volume")
      .onChange(cb_enter)
      .onReleaseOutside(cb_leave)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    ;


    cp5.addTextfield(g_name+ "/volume")
      .setPosition(localx, localy+localoffset)
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("volume")
      .setText(this.volume+"")
      .onChange(cb_enter)
      .onReleaseOutside(cb_leave)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;
    */

    return g;
  }




}
