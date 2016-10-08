class OscCueNode extends CueNode {
  
  OscMessage message;
  
  OscCueNode(String msg, float preWait, float runningTime, float postWait) {
    this(msg, msg, preWait, runningTime, postWait);
  }

  OscCueNode(String description, String msg, float preWait, float runningTime, float postWait) {
    super(description, preWait, runningTime, postWait);
    this.message = new OscMessage(msg);
  }

  OscCueNode(String description, OscMessage message, float preWait, float runningTime, float postWait) {
    super(description, preWait, runningTime, postWait);
    this.message = message;
  }

  void doBeginCue(Blackboard agent) {
    oscP5.send(message, remoteLocation);
  }
}
