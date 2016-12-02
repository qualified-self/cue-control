class BlackboardSetNode extends BaseNode {

	String blackboardKey;
  Expression expression;

  public BlackboardSetNode(String blackboardKey, Object expression) {
		this.blackboardKey = blackboardKey;
    this.expression = new Expression(expression);
  }

  String getDefaultDescription() { return toString(); }

  public State doExecute(Blackboard agent)
	{
    try {
			agent.put(blackboardKey, expression.eval(agent));
      return State.SUCCESS;
    }
    catch (Exception e) {
      System.out.println("ERROR: " + e.toString());
			return State.FAILURE;
    }

	}

  public void doInit(Blackboard agent) {}

  public String toString() {
    return "$" + blackboardKey + " = " + expression;
  }
}
