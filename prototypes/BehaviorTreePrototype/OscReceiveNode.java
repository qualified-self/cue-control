import oscP5.*;

public class OscReceiveNode extends BaseNode
{
	String varName;
  String message;
	Object value;

	float timeOut;

	boolean valueReceived;
	boolean hasStarted;

	State stateOnNoValueReceived;

	Chrono chrono;

	OscP5 oscP5;

	public OscReceiveNode(String message, String varName)
	{
		this(message, varName, BehaviorTreePrototype.instance().oscRecvPort());
	}

	public OscReceiveNode(String message, String varName, int oscRecvPort)
	{
		this(message, varName, oscRecvPort, State.RUNNING);
	}

	public OscReceiveNode(String message, String varName, int oscRecvPort, float timeOut)
	{
		this(message, varName, oscRecvPort, State.RUNNING, timeOut);
	}

	OscReceiveNode(String message, String varName, int oscRecvPort, State stateOnNoValueReceived)
	{
		this(message, varName, oscRecvPort, stateOnNoValueReceived, 0);
	}

	OscReceiveNode(String message, String varName, int oscRecvPort, State stateOnNoValueReceived, float timeOut)
	{
		this("$" + varName + " =" + message + " [port=" + oscRecvPort + "]", message, varName, oscRecvPort, stateOnNoValueReceived, timeOut);
	}

	OscReceiveNode(String description, String message, String varName, int oscRecvPort, State stateOnNoValueReceived, float timeOut)
	{
		super(description);
		this.varName = varName;
		this.stateOnNoValueReceived = stateOnNoValueReceived;
		this.timeOut = timeOut*1000;
    this.message = message;

		chrono = new Chrono(false);

		hasStarted = false;

		oscP5 = BehaviorTreePrototype.instance().addOscP5(oscRecvPort);

    build();
	}

  void build() {
    if (message != null)
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
//		println("OSC received: " + value);
		if (hasStarted)
		{
			this.value = value;
			valueReceived = true;
		}
	}

	public void doInit(Blackboard agent)
	{
		value = null;
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
			agent.put(varName, value);
			valueReceived = false;
			hasStarted = false;
			return State.SUCCESS;
		}
		else if (!chrono.hasPassed((long)timeOut))
			return State.RUNNING;
		else
			return stateOnNoValueReceived;
	}


}
