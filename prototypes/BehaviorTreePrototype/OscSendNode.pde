class OscSendNode extends CueNode {

  String addrPattern;
  Expression argExpression;

  OscSendNode(String addrPattern) {
    this(addrPattern, addrPattern, null, 0, 0);
  }

  OscSendNode(String addrPattern, String arg) {
    this(addrPattern, addrPattern, arg, 0, 0);
  }

  OscSendNode(String addrPattern, float preWait, float postWait) {
    this(addrPattern, addrPattern, null, preWait, postWait);
  }

  OscSendNode(String addrPattern, String arg, float preWait, float postWait) {
    this(addrPattern+" "+arg, addrPattern, arg, preWait, postWait);
  }

  OscSendNode(String description, String addrPattern, String arg, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    this.addrPattern = addrPattern;
    argExpression = (arg != null ? new Expression(arg) : null);
  }

  boolean doBeginCue(Blackboard agent) {
    OscMessage message = new OscMessage(addrPattern);
    try
    {
      if (argExpression != null)
        message.add(new Object[] { argExpression.eval(agent) });
      oscP5.send(message, remoteLocation);
    } catch (Exception e) {
      println("Exception " + e.toString());
      return false; // fails
    }

    return true;
  }
}
