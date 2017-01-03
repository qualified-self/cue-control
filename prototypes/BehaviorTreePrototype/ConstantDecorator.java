class ConstantDecorator extends Decorator {

		State state;

  	public ConstantDecorator(String state)
  	{
      this.state = Utils.stringToState(state);
      if (state == null)
        throw new Exception("Undefined state: " + state + ".");
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
