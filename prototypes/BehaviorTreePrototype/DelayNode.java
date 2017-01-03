import processing.core.PApplet;

class DelayNode extends BaseNode {

	Chrono chrono;
  Expression timeOut;
  float currentTimeOut;

	public DelayNode(float timeOut) {
		this(Float.toString(timeOut));
	}

	public DelayNode(String description, float timeOut) {
    this(description, Float.toString(timeOut));
	}

	public DelayNode(String timeOut) {
		this(timeOut, timeOut);
	}

	public DelayNode(String description, String timeOut) {
		super(description);
		this.timeOut = new Expression(timeOut);
		chrono = new Chrono(false);
	}

  public State doExecute(Blackboard agent) {
		if (!chrono.isRunning())
    {
      try {
        currentTimeOut = ((Number)timeOut.eval(agent)).floatValue();
      }
      catch (Exception e) {
        Console.instance().log(e.toString());
        currentTimeOut = 0;
      }
			chrono.restart();
    }

		return (chrono.hasPassed(PApplet.ceil(currentTimeOut*1000)) ? State.SUCCESS : State.RUNNING);
  }

  public void doInit(Blackboard agent)
  {
    chrono.stop();
  }

  String getDynamicDescription() {
		float timeLeft = currentTimeOut - chrono.elapsed()/1000.0f;
		return PApplet.nf(PApplet.max(timeLeft, 0), 0, 1) + " / " + PApplet.nf(currentTimeOut, 0, 1);
  }

}
