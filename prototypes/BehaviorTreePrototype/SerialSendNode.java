import processing.serial.*;

class SerialSendNode extends CueNode {

  Expression argExpression;

  public SerialSendNode(Object arg) {
    this(arg.toString(), arg, 0.f, 0.f);
  }

  SerialSendNode(Object arg, float preWait, float postWait) {
    this(arg.toString(), arg, preWait, postWait);
  }

  SerialSendNode(String description, Object arg, float preWait, float postWait) {
    super(description, preWait, 0, postWait);
    argExpression = (arg != null ? new Expression(arg) : null);
  }

  boolean doBeginCue(Blackboard agent) {
    try
    {
			Object value = argExpression.eval(agent);
      if (value instanceof Number) // force to send floats at all time
        value = new Float(((Number)value).floatValue());
      BehaviorTreePrototype.instance().serial().write(value.toString() + "\n");
    } catch (Exception e) {
      BehaviorTreePrototype.instance().println("Exception " + e.toString());
      return false; // fails
    }

    return true;
  }
}
