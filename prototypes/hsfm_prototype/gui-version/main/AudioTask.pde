/************************************************
 ** Audio task class ****************************
 ************************************************
 ** implementing a task for audio
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

////////////////////////////////////////

class AudioTask extends Task {

  //audio variables
  private AudioPlayer soundfile;
  private String filename;

  //contructor loading the file
  public AudioTask (String taskname, String filename) {
    super(taskname);
    this.filename  = filename;
    this.soundfile = minim.loadFile(filename);
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

  AudioTask clone() {
    return new AudioTask(this.name, this.filename);
  }

  //implementing the execute method (play the music)
  void run () {
    soundfile.play();
    println("Task " + this + " playing!");
    this.status = Status.RUNNING;
  }

  void stop() {
    soundfile.pause();
    soundfile.rewind();
    this.status = Status.INACTIVE;
  }

  void update_status() {
    boolean playing = soundfile.isPlaying();

    if (playing)
      this.status = Status.RUNNING;
    else
      this.status = Status.DONE;
  }

  Group load_gui_elements(State s) {
    Group g = cp5.addGroup(s.name + " " + this.get_name())
    //.setPosition(x, y) //change that?
    .setHeight(12)
    .setBackgroundHeight(50)
    .setColorBackground(color(255, 50)) //color of the task
    .setBackgroundColor(color(255, 25)) //color of task when openned
    .setLabel(this.get_prefix() + "   " + this.get_name())
    ;

    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    int localx = 10, localy = 15, localoffset = 40;
    int w = g.getWidth()-10;

    cp5.addTextfield("filename")
      .setPosition(localx, localy)
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("filename")
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    ;

    // add a vertical slider
    cp5.addSlider("volume")
      .setPosition(localx, localy+localoffset)
      .setSize(w, 15)
      .setRange(0, 1)
      .setGroup(g)
      .setValue(1)
      .setLabel("volume")
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    ;

    // reposition the Label for controller 'slider'
    cp5.getController("volume").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    cp5.getController("volume").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    return g;
  }

}
