class SoundCueNode extends CueNode {

  AudioPlayer player;

  SoundCueNode(String fileName) {
    this(fileName, fileName, 0, 0);
  }

  SoundCueNode(String fileName, float preWait, float postWait) {
    this(fileName, fileName, preWait, postWait);
  }

  SoundCueNode(String description, String fileName, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    player = minim.loadFile(fileName);
    runningTime = player.getMetaData().length() / 1000.0;
  }

  boolean doBeginCue(Blackboard agent) {
    player.play();
    return true;
  }

  boolean doEndCue(Blackboard agent) {
    player.pause();
    player.rewind();
    return true;
  }

  public void doInit(Blackboard agent)
  {
    super.doInit(agent);
    endCue(agent);
  }

}
