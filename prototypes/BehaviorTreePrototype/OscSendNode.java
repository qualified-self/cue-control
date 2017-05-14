import oscP5.*;
import netP5.*;

class OscSendNode extends CueNode {

  String addrPattern;
  Expression argExpression;

  NetAddress remoteLocation;

  public OscSendNode(String addrPattern) {
    this(addrPattern, BehaviorTreePrototype.instance().oscSendIp(), BehaviorTreePrototype.instance().oscSendPort());
  }

  public OscSendNode(String addrPattern, Object arg) {
    this(addrPattern, arg, BehaviorTreePrototype.instance().oscSendIp(), BehaviorTreePrototype.instance().oscSendPort());
  }

  public OscSendNode(String addrPattern, String oscSendIp, int oscSendPort) {
    this(addrPattern, null, oscSendIp, oscSendPort);
  }

  public OscSendNode(String addrPattern, Object arg, String oscSendIp, int oscSendPort) {
    this(addrPattern, arg, oscSendIp, oscSendPort, 0, 0);
  }

  OscSendNode(String addrPattern, String oscSendIp, int oscSendPort, float preWait, float postWait) {
    this(addrPattern, null, oscSendIp, oscSendPort, preWait, postWait);
  }

  OscSendNode(String addrPattern, Object arg, String oscSendIp, int oscSendPort, float preWait, float postWait) {
    this(addrPattern + (arg != null ? " " + arg : "") + " [" + oscSendPort + "@" + oscSendIp + "]", addrPattern, arg, oscSendIp, oscSendPort, preWait, postWait);
  }

  OscSendNode(String description, String addrPattern, Object arg, String oscSendIp, int oscSendPort, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    this.addrPattern = addrPattern;
    argExpression = (arg != null ? new Expression(arg) : null);

 		remoteLocation = new NetAddress(oscSendIp, oscSendPort);
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
      BehaviorTreePrototype.instance().oscP5().send(message, remoteLocation);
    } catch (Exception e) {
      Console.instance().error("Exception " + e.toString());
      return false; // fails
    }

    return true;
  }
}
