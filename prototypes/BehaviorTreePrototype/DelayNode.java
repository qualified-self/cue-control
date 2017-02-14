import processing.core.PApplet;

class DelayNode extends BaseNode {

	Chrono chrono;
  Expression timeOut;
  float currentTimeOut;
  boolean chronoNeedsRestart;

	public DelayNode(double timeOut) {
		this((float)timeOut);
	}

	public DelayNode(String description, double timeOut) {
    this(description, (float)timeOut);
	}

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
    chronoNeedsRestart = true;
	}

  public State doExecute(Blackboard agent) {
		if (chronoNeedsRestart)
    {
      try {
        currentTimeOut = ((Number)timeOut.eval(agent)).floatValue();
      }
      catch (Exception e) {
        Console.instance().error(e.toString());
        currentTimeOut = 0;
			  chrono.restart();
        return State.FAILURE;
      }

			chrono.restart();
      chronoNeedsRestart = false;
    }

		if (chrono.hasPassed(PApplet.ceil(currentTimeOut*1000))) {
      chronoNeedsRestart = true;
			return State.SUCCESS;
    }
		else
			return State.RUNNING;
  }

  public void doInit(Blackboard agent)
  {
    chrono.stop();
		chronoNeedsRestart = true;
  }

  String getDynamicDescription() {
		float timeLeft = currentTimeOut - chrono.elapsed()/1000.0f;
		return PApplet.nf(PApplet.max(timeLeft, 0), 0, 1) + " / " + PApplet.nf(currentTimeOut, 0, 1);
  }

  void setPlayState(boolean playing) {
    super.setPlayState(playing);
    if (playing)
      chrono.resume();
    else
      chrono.stop();
  }

}
