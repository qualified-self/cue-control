class ConstantNode extends BaseNode
{
	State state;
	public ConstantNode(String state)
	{
    this.state = Utils.stringToState(state);
    // HACK: to avoid errors
    if (this.state == null) this.state = State.SUCCESS;
	}

	ConstantNode(State state)
	{
		this.state = state;
	}

  String getDefaultDescription() { return Utils.stateToString(state); }

  public State doExecute(Blackboard agent) { return state; }
  public void doInit(Blackboard agent) {}

}
