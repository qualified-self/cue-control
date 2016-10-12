class OscReceiveNode extends CueNode
{
	String varName;
	double value;
	boolean valueReceived;
	boolean hasStarted;

	State stateOnNoValueReceived;

	OscReceiveNode(String message, String varName)
	{
		this(message, varName, State.RUNNING);
	}

	OscReceiveNode(String message, String varName, State stateOnNoValueReceived)
	{
		super(message, 0, 0, 0);
		this.varName = varName;
		this.stateOnNoValueReceived = stateOnNoValueReceived;
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

	public void doInit(Blackboard agent)
	{
		value = 0;
		valueReceived = false;
	}

	public State doExecute(Blackboard agent)
	{
		hasStarted = true;
		if (valueReceived)
		{
			agent.put(varName, new Double(value));
			valueReceived = false;
			hasStarted = false;
			return State.SUCCESS;
		}
		else
			return stateOnNoValueReceived;
	}

}
