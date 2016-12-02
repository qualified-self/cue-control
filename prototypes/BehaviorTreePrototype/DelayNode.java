import processing.core.PApplet;

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

		return (chrono.hasPassed(PApplet.ceil(timeOut*1000)) ? State.SUCCESS : State.RUNNING);
  }

  public void doInit(Blackboard agent)
  {
    chrono.stop();
  }

  String getDefaultDescription() {
		float timeLeft = timeOut - chrono.elapsed()/1000.0f;
		return PApplet.nf(PApplet.max(timeLeft, 0), 0, 1);
  }

}
