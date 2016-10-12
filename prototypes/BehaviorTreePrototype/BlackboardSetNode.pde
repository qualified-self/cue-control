class BlackboardSetNode extends BaseNode {

	String blackboardKey;
  Expression expression;

  BlackboardSetNode(String blackboardKey, String expression) {
		this.blackboardKey = blackboardKey;
    this.expression = new Expression(expression);
  }

  String getDefaultDescription() { return toString(); }

  public State doExecute(Blackboard agent)
	{
    try {
			agent.put(blackboardKey, expression.evalAsDouble(agent));
      return State.SUCCESS;
    }
    catch (Exception e) {
      println("ERROR: " + e.toString());
			return State.FAILURE;
    }

	}

  public void doInit(Blackboard agent) {}
  public String type() { return "SET"; }

  public String toString() {
    return "[" + blackboardKey + "] = " + expression;
  }
}
