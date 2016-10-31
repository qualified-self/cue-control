class DelayNode extends BaseNode {

	Chrono chrono;
	float timeOut;

	DelayNode(float timeOut) {
		this(timeOut + "s", timeOut);
	}

	DelayNode(String description, float timeOut) {
		super(description);
		this.timeOut = timeOut;
		chrono = new Chrono(false);
	}

  public State doExecute(Blackboard agent) {
		if (!chrono.isRunning())
			chrono.restart();

		return (chrono.hasPassed(ceil(timeOut*1000)) ? State.SUCCESS : State.RUNNING);
  }

  public void doInit(Blackboard agent)
  {
    chrono.stop();
  }

  public String type() { return "DEL"; }

  String getDefaultDescription() {
		float timeLeft = timeOut - chrono.elapsed()/1000.0f;
		return nf(max(timeLeft, 0), 0, 1);
  }

}
