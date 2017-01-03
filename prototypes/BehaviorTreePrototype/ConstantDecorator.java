class ConstantDecorator extends Decorator {

		State state;

  	public ConstantDecorator(String state) throws Exception
  	{
      this.state = Utils.stringToState(state);
      // HACK: to avoid errors
      if (this.state == null) this.state = State.SUCCESS;
  	}

		ConstantDecorator(State state)
		{
			this.state = state;
		}

	  String getDefaultDescription() { return Utils.stateToString(state); }

	  public State doExecute(Blackboard agent) { return state; }
	  public void doInit(Blackboard agent) {}
	  public String type() { return "CNS"; }
}
