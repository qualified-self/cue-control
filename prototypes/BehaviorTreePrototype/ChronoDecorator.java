class ChronoDecorator extends WhileDecorator {

	float timeOut;

	Chrono chrono;

  public ChronoDecorator(float timeOut) {
		super(new ChronoCondition(timeOut));
		chrono = ((ChronoCondition)condition).getChrono();
//    chrono.stop();
	}

  public void doInit(Blackboard agent) {
    super.doInit(agent);
//    chrono.stop();
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
