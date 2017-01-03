/************************************************ //<>// //<>// //<>// //<>// //<>//
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
  private Minim       minim;
  private AudioPlayer soundfile;
  private String filename;

  //contructor loading the file
  public AudioTask (PApplet p, String taskname, String filename) {
    super(p, taskname);
    this.minim     = new Minim(p);
    this.filename  = filename;
    this.soundfile = minim.loadFile(filename);
  }

  AudioTask clone() {
    return new AudioTask(this.p, this.name, this.filename);
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
}
