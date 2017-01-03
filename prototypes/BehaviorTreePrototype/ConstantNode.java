class ConstantNode extends BaseNode
{
	State state;
	public ConstantNode(String state) throws Exception
	{
    this.state = Utils.stringToState(state);
    if (state == null)
      throw new Exception("Undefined state: " + state + ".");
	}

	ConstantNode(State state)
	{
		this.state = state;
	}

  String getDefaultDescription() { return Utils.stateToString(state); }

  public State doExecute(Blackboard agent) { return state; }
  public void doInit(Blackboard agent) {}

}
