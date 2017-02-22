

import processing.core.PApplet;
import ddf.minim.*;
import controlP5.*;

////////////////////////////////////////

class AudioTask extends Task {

  //audio variables
  transient private AudioPlayer soundfile;
  private String filename;
  private Object  volume;

  //contructor loading the file
  public AudioTask (PApplet p, ControlP5 cp5, String taskname, String filename) {
    super(p, cp5, taskname);
    this.filename  = filename;
    //repeat what sofian did in his prototype
    build(p, cp5);
    this.volume = new Expression("1.0");
  }
  /*
  //contructor loading the file
  public AudioTask (PApplet p, String taskname, String filename) {
    super(p, taskname);
    this.minim     = new Minim(p);
    this.filename  = filename;
    this.soundfile = minim.loadFile(filename);
  }
  */

  void build(PApplet p, ControlP5 cp5) {
    this.p = p;
    this.cp5 = cp5;
    this.soundfile = ZenStates.instance().minim().loadFile(filename);
  }

  AudioTask clone_it() {
    return new AudioTask(this.p, this.cp5, this.name, this.filename);
  }

  void update_name(String name) {
    this.filename = name;
    this.name     = name;
    this.soundfile = ZenStates.instance().minim().loadFile(this.filename);
  }

  void set_volume(Object new_volume) {
    Object o = evaluate_value(new_volume);

    if (o instanceof Float || o instanceof Double || o instanceof Integer)
      volume = new_volume;
    else
      volume = new Expression("0.0");
  }

  //input is in between 0 and one. result is between -80 and 14 (dB).
  void update_volume() {
    float newvolume = 0;

    Object o = evaluate_value(volume);

    if (o instanceof Float)
      newvolume = (Float)o;
    if (o instanceof Double)
      newvolume = ((Double)o).floatValue();
    if (o instanceof Integer)
      newvolume = ((Integer)o).floatValue();

    p.println("newvolume: " + newvolume);

    newvolume = p.constrain(newvolume, 0.f, 1.f);
    float mapped_volume = map(newvolume, 0.f, 1.f, -70.f, 14.f);
    if (soundfile!=null)
      soundfile.setGain(mapped_volume);
  }

  /*
  void set_volume(double newvolume) {
    set_volume((float)newvolume);
  }
  */

  //taken from https://forum.processing.org/one/topic/i-need-to-know-how-exactly-map-function-works.html
  float map(float value, float istart, float istop, float ostart, float ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
  }

  //implementing the execute method (play the music)
  void run () {
    soundfile.play();
    //println("Task " + this + " playing!");
    this.status = Status.RUNNING;
  }

  void stop() {
    super.stop();
    soundfile.pause();
    soundfile.rewind();
    this.status = Status.INACTIVE;
  }

  void update_status() {
    update_volume();
    boolean playing = soundfile.isPlaying();

    if (playing)
      this.status = Status.RUNNING;
    else
      this.status = Status.DONE;
  }

  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            String s = theEvent.getController().getName();

            if (s.equals(get_gui_id() + "/filename")) {
                String newFilename = theEvent.getController().getValueLabel().getText();
                update_name(newFilename);
                System.out.println(s + " " + newFilename);
            }
            /*
            if (s.equals(get_gui_id() + "/volume")) {
                float newvolume = theEvent.getController().getValue();
                set_volume(newvolume);
                System.out.println(s + " " + newvolume);
            }
            */
            if (s.equals(get_gui_id() + "/volume")) {
                String newvalue = theEvent.getController().getValueLabel().getText();
                set_volume(new Expression(newvalue));
                System.out.println(s + " " + newvalue);
            }
          }
    };
  }

  CallbackListener generate_callback_leave() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {
            //println(name + " was unfocused");

            String s = theEvent.getController().getName();
            //ControlP5 cp5 = HFSMPrototype.instance().cp5();

            /*
            if (s.equals(get_gui_id() + "/filename")) {
                String newFilename = theEvent.getController().getValueLabel().getText();
                String oldFilename = filename;

                System.out.println(newFilename +  " - " + oldFilename);

                //if the user tried to change but did not press enter
                if (!newFilename.equals(oldFilename)) {
                  //resets the test for the original
                  Textfield t = (Textfield)cp5.get(s);
                  t.setText(oldFilename);
                }
            }
            */

            String newtext = theEvent.getController().getValueLabel().getText();
            String oldtext = "";

            if (s.equals(get_gui_id() + "/filename"))
              oldtext = filename;
            else if (s.equals(get_gui_id() + "/volume"))
              oldtext = volume.toString();
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

  Group load_gui_elements(State s) {
    //do we really need this?
    //this.parent = s;

    CallbackListener cb_enter = generate_callback_enter();
    CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();

    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    Group g = cp5.addGroup(g_name)
    //.setPosition(x, y) //change that?
    .setHeight(12)
    .setBackgroundHeight(50)
    .setColorBackground(p.color(255, 50)) //color of the task
    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    .setLabel(this.get_prefix() + "   " + this.get_name())
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
      .onChange(cb_enter)
      .onReleaseOutside(cb_leave)
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
      .onReleaseOutside(cb_leave)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
      ;


    return g;
  }

  void reset_gui_fields() {
    String g_name = this.get_gui_id();
    String nv;
    nv = ((Textfield)cp5.get(g_name+"/filename")).getText();
    update_name(nv);
    nv = ((Textfield)cp5.get(g_name+"/volume")).getText();
    set_volume(new Expression(nv));
  }

}
