public class SerialReceiveNode extends BaseNode
{
	String varName;
	Object value;

	float timeOut;

	boolean valueReceived;
	boolean hasStarted;

	State stateOnNoValueReceived;

	Chrono chrono;

	public SerialReceiveNode(String varName)
	{
		this(varName, State.RUNNING);
	}

	SerialReceiveNode(String varName, State stateOnNoValueReceived)
	{
		this(varName, varName, stateOnNoValueReceived, 0.0f);
	}

	SerialReceiveNode(String varName, State stateOnNoValueReceived, float timeOut)
	{
		this(varName, varName, stateOnNoValueReceived, timeOut);
	}

	SerialReceiveNode(String description, String varName, State stateOnNoValueReceived, float timeOut)
	{
		super(description);
		this.varName = varName;
		this.stateOnNoValueReceived = stateOnNoValueReceived;
		this.timeOut = timeOut*1000;

		chrono = new Chrono(false);

		hasStarted = false;

    build();
	}


	public void doInit(Blackboard agent)
	{
		value = null;
		hasStarted = false;
		// Throw out the first reading, in case we started reading
  	// in the middle of a string from the sender
		BehaviorTreePrototype.instance().serial().readStringUntil('\n');
	  chrono.restart();
	}

	public State doExecute(Blackboard agent)
	{
		if (!hasStarted)
		{
			init(agent);
			hasStarted = true;
		}

		if (BehaviorTreePrototype.instance().serial().available() > 0) {
			value = Float.parseFloat(BehaviorTreePrototype.instance().serial().readStringUntil('\n'));
			agent.put(varName, value);
			hasStarted = false;
			return State.SUCCESS;
		}
		else if (!chrono.hasPassed((long)timeOut))
			return State.RUNNING;
		else
			return stateOnNoValueReceived;
	}


}
