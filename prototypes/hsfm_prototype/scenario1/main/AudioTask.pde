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

  //contructor loading the file
  public AudioTask (PApplet p, String taskname, String filename) {
    super(taskname);
    this.minim     = new Minim(p);
    this.soundfile = minim.loadFile(filename);
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
