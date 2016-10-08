class OscToBlackboard extends CueNode
{
	String varName;
	int value;
	boolean valueReceived;
	boolean hasStarted;

	State stateOnNoValueReceived;

	OscToBlackboard(String message, String varName)
	{
		this(message, varName, State.RUNNING);
	}

	OscToBlackboard(String message, String varName, State stateOnNoValueReceived)
	{
		super(message, 0, 0, 0);
		this.varName = varName;
		this.stateOnNoValueReceived = stateOnNoValueReceived;
		hasStarted = false;
		oscP5.plug(this, "process", message);
	}

	void process(int value)
	{
		if (hasStarted)
		{
			println("received value " + value);
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
			agent.put(varName, new Integer(value));
			valueReceived = false;
			hasStarted = false;
			return State.SUCCESS;
		}
		else
			return stateOnNoValueReceived;
	}

}
