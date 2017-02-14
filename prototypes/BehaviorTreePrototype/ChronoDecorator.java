class ChronoDecorator extends WhileDecorator {

	float timeOut;

	Chrono chrono;

  boolean chronoNeedsRestart;
  boolean chronoTimedOut;

	public ChronoDecorator(double timeOut) {
		this((float)timeOut);
	}

  public ChronoDecorator(float timeOut) {
		super(new ChronoCondition(timeOut));
		chrono = ((ChronoCondition)condition).getChrono();
//    chrono.stop();
    chronoNeedsRestart = true;
    chronoTimedOut = false;
	}

  public void doInit(Blackboard agent) {
    super.doInit(agent);
    // WONTFIX: There is a problem when you reset the system (CTRL+R) the
    // chrono is not reset. There is no way to fix this in the current system.
    // We need to think better when programming the application: init of node should
    // not necessarily trigger init of decorator.
    if (chronoTimedOut) {
      chrono.stop();
      chronoNeedsRestart = true;
    }
  }

  public State doExecute(Blackboard agent) {
		if (chronoNeedsRestart)
		{
			chrono.restart();
      chronoNeedsRestart = false;
      chronoTimedOut = false;
		}

		State status = super.doExecute(agent);
		if (status != State.RUNNING) {
      chrono.stop();
      chronoNeedsRestart = true;
      chronoTimedOut = true;
    }

		return status;
  }

  void setPlayState(boolean playing) {
    super.setPlayState(playing);
    if (playing)
      chrono.resume();
    else
      chrono.stop();
  }

}
