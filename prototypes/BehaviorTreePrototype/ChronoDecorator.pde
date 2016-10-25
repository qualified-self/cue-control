class ChronoDecorator extends WhileDecorator {

	float timeOut;

	Chrono chrono;

  ChronoDecorator(float timeOut) {
		super(new ChronoCondition(timeOut));
		chrono = ((ChronoCondition)condition).getChrono();
	}

  public void doInit(Blackboard agent) {
    super.doInit(agent);
  }

  public State doExecute(Blackboard agent) {
		if (!chrono.isRunning())
		{
			chrono.restart();
		}

		State status = super.doExecute(agent);
		if (status != State.RUNNING)
			chrono.stop();

		return status;
  }
}
