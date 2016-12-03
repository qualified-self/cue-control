public class OscBlackboardTask extends BlackboardTask
{
	String varName;
  String message;
	Object value;

	boolean valueReceived;
	boolean hasStarted;

	OscBlackboardTask(String message, String varName, Object startingValue)
	{
		this.varName = varName;
    this.message = message;

		value = null;
		valueReceived = false;
		hasStarted = false;

    // Default.
    process(startingValue);

    build();
	}

  void build() {
    if (message != null)
		  BehaviorTreePrototype.instance().oscP5().plug(this, "process", message);
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
		BehaviorTreePrototype.instance().println("OSC blackboard task received: " + value);
		this.value = value;
		valueReceived = true;
	}

  void init(Blackboard agent)
  {
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
