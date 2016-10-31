class OscReceiveNode extends BaseNode
{
	String varName;
	float timeOut;

	double value;
	boolean valueReceived;
	boolean hasStarted;

	State stateOnNoValueReceived;

	OscReceiveNode(String message, String varName)
	{
		this(message, varName, State.RUNNING);
	}

	OscReceiveNode(String message, String varName, float timeOut)
	{
		this(message, varName, State.RUNNING, timeOut);
	}

	OscReceiveNode(String message, String varName, State stateOnNoValueReceived)
	{
		this(message, varName, stateOnNoValueReceived, 0);
	}

	OscReceiveNode(String message, String varName, State stateOnNoValueReceived, float timeOut)
	{
		this("[" + varName + "] =" + message, message, varName, stateOnNoValueReceived, timeOut);
	}

	OscReceiveNode(String description, String message, String varName, State stateOnNoValueReceived, float timeOut)
	{
		super(description);
		this.varName = varName;
		this.stateOnNoValueReceived = stateOnNoValueReceived;
		this.timeOut = timeOut*1000;

		chrono = new Chrono(false);

		hasStarted = false;

		oscP5.plug(this, "process", message);
	}

	void process(double value)
	{
		if (hasStarted)
		{
			this.value = value;
			valueReceived = true;
		}
	}

	void process(int value)   { process((double)value);}
	void process(float value) { process((double)value); }

	public void doInit(Blackboard agent)
	{
		value = 0;
		valueReceived = false;
		hasStarted = false;
	  chrono.restart();
	}

	public State doExecute(Blackboard agent)
	{
		if (!hasStarted)
		{
			init(agent);
			hasStarted = true;
		}

		if (valueReceived)
		{
			agent.put(varName, new Double(value));
			valueReceived = false;
			hasStarted = false;
			return State.SUCCESS;
		}
		else if (!chrono.hasPassed((long)timeOut))
			return State.RUNNING;
		else
			return stateOnNoValueReceived;
	}

  public String type() { return "RCV"; }

	Chrono chrono;

}
