import processing.core.PApplet;

class BlackboardRampNode extends BlackboardSetNode {

	Chrono chrono;
	float timeOut;

  Expression from;
  float fromValue;
  float toValue;
  float currentValue;

  public BlackboardRampNode(String blackboardKey, Object to, float timeOut) {
    this(blackboardKey, "$"+blackboardKey, to, timeOut);
  }

  public BlackboardRampNode(String blackboardKey, Object from, Object to, float timeOut) {
    super(blackboardKey, to);
    this.from = new Expression(from);
    this.timeOut = timeOut;
    chrono = new Chrono(false);
  }

  String getDefaultDescription() { return toString(); }

  public State doExecute(Blackboard agent)
	{
    try {
      if (!chrono.isRunning()) {
        chrono.restart();
        fromValue = ((Number)from.eval(agent)).floatValue();
        toValue   = ((Number)expression.eval(agent)).floatValue();
      }

      float elapsed = chrono.seconds();
      State state = State.RUNNING;
      if (elapsed >= timeOut) {
        elapsed = timeOut;
        state = State.SUCCESS;
      }

      currentValue = PApplet.map(elapsed, 0, timeOut, fromValue, toValue);

			agent.put(blackboardKey, currentValue);
      return state;
    }
    catch (Exception e) {
      Console.instance().log(e.getMessage());
			return State.FAILURE;
    }

	}

  public void doInit(Blackboard agent) {
    chrono.stop();
  }

  public String toString() {
    return "$" + blackboardKey + " = " + from + " -> " + expression +
           " in " + PApplet.nf(timeOut, 0, 1) + "s" +
           " (current: " + PApplet.nf(currentValue, 0, 1) + ")";
  }

}
