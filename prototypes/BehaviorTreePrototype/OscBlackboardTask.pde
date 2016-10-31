class OscBlackboardTask extends BlackboardTask
{
	String varName;
	Object value;

	boolean valueReceived;
	boolean hasStarted;

	OscBlackboardTask(String message, String varName)
	{
		this.varName = varName;

		value = null;
		valueReceived = false;
		hasStarted = false;

		oscP5.plug(this, "process", message);
	}

	void process(int value) {
		process(new Integer(value));
	}

	void process(float value) {
		process(new Float(value));
	}

	void process(double value) {
		process(new Double(value));
	}

	void process(String value) {
		process( (Object) value);
	}

	void process(Object value)
	{
		println("OSC blackboard task received: " + value);
		this.value = value;
		valueReceived = true;
	}

	void execute(Blackboard agent)
	{
		if (valueReceived)
		{
			agent.put(varName, value);
			valueReceived = false;
		}
	}
}
