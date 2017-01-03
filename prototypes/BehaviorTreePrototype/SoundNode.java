import ddf.minim.AudioPlayer;

class SoundNode extends CueNode {

  transient AudioPlayer player;

  String fileName;

  public SoundNode(String fileName) {
    this(fileName, fileName, 0, 0);
  }

  public SoundNode(String fileName, float preWait, float postWait) {
    this(fileName, fileName, preWait, postWait);
  }

  public SoundNode(String description, String fileName, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    this.fileName = fileName;
    build();
  }

  void build() {
    if (fileName != null) {
      player = BehaviorTreePrototype.instance().minim().loadFile(fileName);
      runningTime = player.getMetaData().length() / 1000.0f;
    }
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
