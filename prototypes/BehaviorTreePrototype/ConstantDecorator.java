class ConstantDecorator extends Decorator {

		State state;

		ConstantDecorator(State state)
		{
			this.state = state;
		}

	  String getDefaultDescription() { return Utils.stateToString(state); }

	  public State doExecute(Blackboard agent) { return state; }
	  public void doInit(Blackboard agent) {}
	  public String type() { return "CNS"; }
}
