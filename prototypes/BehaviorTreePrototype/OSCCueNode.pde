class OscCueNode extends CueNode {

  OscMessage message;

  OscCueNode(String msg) {
    this(msg, msg, 0, 0);
  }

  OscCueNode(String msg, float preWait, float postWait) {
    this(msg, msg, preWait, postWait);
  }

  OscCueNode(String description, String msg, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    this.message = new OscMessage(msg);
  }

  OscCueNode(String description, OscMessage message, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    this.message = message;
  }

  void doBeginCue(Blackboard agent) {
    oscP5.send(message, remoteLocation);
  }
}
