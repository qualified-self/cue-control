import oscP5.*;

class OscSendNode extends CueNode {

  String addrPattern;
  Expression argExpression;

  public OscSendNode(String addrPattern) {
    this(addrPattern, addrPattern, null, 0, 0);
  }

  public OscSendNode(String addrPattern, Object arg) {
    this(addrPattern+" "+arg, addrPattern, arg, 0, 0);
  }

  OscSendNode(String addrPattern, float preWait, float postWait) {
    this(addrPattern, addrPattern, null, preWait, postWait);
  }

  OscSendNode(String addrPattern, Object arg, float preWait, float postWait) {
    this(addrPattern+" "+arg, addrPattern, arg, preWait, postWait);
  }

  OscSendNode(String description, String addrPattern, Object arg, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    this.addrPattern = addrPattern;
    argExpression = (arg != null ? new Expression(arg) : null);
  }

  boolean doBeginCue(Blackboard agent) {
    OscMessage message = new OscMessage(addrPattern);
    try
    {
      if (argExpression != null) {
        Object value = argExpression.eval(agent);
        if (value instanceof Number) // force to send floats at all time
          value = new Float(((Number)value).floatValue());
        message.add(new Object[] { value });
      }
      BehaviorTreePrototype.instance().oscP5().send(message, BehaviorTreePrototype.instance().remoteLocation());
    } catch (Exception e) {
      BehaviorTreePrototype.instance().println("Exception " + e.toString());
      return false; // fails
    }

    return true;
  }
}
