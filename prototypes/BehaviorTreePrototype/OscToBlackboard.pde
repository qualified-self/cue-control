class OscToBlackboard extends CueNode
{
	String varName;
	int value;
	boolean valueReceived;

	OscToBlackboard(String message, String varName)
	{
		super(message, 0, 0, 0);
		this.varName = varName;
		oscP5.plug(this, "process", message);
	}

	void process(int value)
	{
		println("received value " + value);
		this.value = value;
		valueReceived = true;
	}

	public void doInit(Blackboard agent)
	{
		value = 0;
		valueReceived = false;
	}

	public State doExecute(Blackboard agent)
	{
		if (valueReceived)
		{
			agent.put(varName, new Integer(value));
			return State.SUCCESS;
		}
		else
			return State.RUNNING;
	}

}
