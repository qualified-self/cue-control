import oscP5.*;
import oscP5.*;

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
      Object value = argExpression.eval(agent);
      if (value instanceof Double)
        value = new Float(((Double)value).floatValue());
      if (argExpression != null)
        message.add(new Object[] { value });
      BehaviorTreePrototype.instance().oscP5().send(message, BehaviorTreePrototype.instance().remoteLocation());
    } catch (Exception e) {
      BehaviorTreePrototype.instance().println("Exception " + e.toString());
      return false; // fails
    }

    return true;
  }
}
