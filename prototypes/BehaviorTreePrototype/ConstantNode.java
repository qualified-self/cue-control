class ConstantNode extends BaseNode
{
	State state;
	ConstantNode(State state)
	{
		this.state = state;
	}

  String getDefaultDescription() { return Utils.stateToString(state); }

  public State doExecute(Blackboard agent) { return state; }
  public void doInit(Blackboard agent) {}

}
