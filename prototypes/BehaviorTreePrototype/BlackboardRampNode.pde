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
        println("from: " + fromValue);
        println("to: " + toValue);
      }

      float elapsed = chrono.seconds();
      State state = State.RUNNING;
      if (elapsed >= timeOut) {
        elapsed = timeOut;
        state = State.SUCCESS;
      }

      currentValue = map(elapsed, 0, timeOut, fromValue, toValue);
      println("elapsed: " + elapsed + " currevalue:" + currentValue);

			agent.put(blackboardKey, currentValue);
      return state;
    }
    catch (Exception e) {
      System.out.println("ERROR: " + e.toString());
			return State.FAILURE;
    }

	}

  public void doInit(Blackboard agent) {
    chrono.stop();
  }

  public String toString() {
    return "$" + blackboardKey + " = " + from + " -> " + expression + " in " + timeOut + "s" + " (current: " + currentValue + ")";
  }

}
