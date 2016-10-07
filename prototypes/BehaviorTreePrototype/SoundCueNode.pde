class SoundCueNode extends CueNode {

  AudioPlayer player;

  SoundCueNode(String fileName, float preWait, float postWait) {
    this(fileName, fileName, preWait, postWait);
  }

  SoundCueNode(String description, String fileName, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    player = minim.loadFile(fileName);
    runningTime = player.getMetaData().length() / 1000.0;
  }

  void beginCue(Blackboard agent) {
    player.play();
  }

  void endCue(Blackboard agent) {
    player.pause();
    player.rewind();
  }
  
  public void doInit(Blackboard agent)
  {
    super.doInit(agent);
    endCue(agent);
  }

}