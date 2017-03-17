


import oscP5.*;
import netP5.*;
import controlP5.*;
import processing.core.PApplet;

////////////////////////////////////////
//implementing a task for OSC messages
public abstract class RemoteOSCTask extends Task {

	//variables to store my osc connection
	// private OscP5      oscP5;
	//transient private NetAddress broadcast;
	//private OscMessage message;
	protected Object[]    content;
	protected String      message;
	transient protected NetAddress broadcast;
	transient protected OscP5      oscP5;

	//static String    ip   = "192.168.1.11";
	//static String    ip   = "192.168.1.101";
	//static String    ip   = "localhost";
	static String    ip = "";
	static int       port = -1;

	//contructor loading the file
	public RemoteOSCTask (PApplet p, ControlP5 cp5, String id) {
		super(p, cp5, id);

		//IP SHOULD BE REDEFINED HERE
		//this.ip        =  "192.168.1.10";
		//PORT SHOULD BE REDEFINED HERE
		//this.port      = 12000;
		this.build(p, cp5);
	}

	void build(PApplet p, ControlP5 cp5) {
		//initializing ip and port, in case there are none
		if (ip.equals("") || port == -1) {
			ip = ZenStates.instance().get_remote_ip();
			port = ZenStates.instance().get_remote_port();
		}

		this.p = p;
		this.cp5 = cp5;
		this.broadcast = new NetAddress(ip, port);
		this.oscP5 = ZenStates.instance().oscP5();

	}

	void run () {
		if (!should_run())
			return;


		this.status = Status.RUNNING;

		OscMessage msg = create_message();

		oscP5.send(msg, broadcast);

		//if (debug)
		System.out.println("sending OSC message to: " + broadcast.toString() + ". content: " + msg.toString());
		this.status = Status.DONE;
	}

	//returns a new message suited for this task
	OscMessage create_message() {

		//creates the oscmessage to be returned
		OscMessage om = new OscMessage(this.message);

		//gets all the content
		Object[] args = new Object[content.length];

		//evaluates each item of the osc message
		for (int i = 0; i < args.length; i++) {
			args[i] = evaluate_value(content[i]);

			//fixes the problems for in sending double in osc messages
			if (args[i] instanceof Double)
				args[i] = ((Double)args[i]).floatValue();
		}

		//clearing the arguements and adding the new values
		om.add(args);

		return om;
	}

	void stop() {
		super.stop();
		//Object[] args = message.arguments();
		//message.clear();
		//update_message(args);
		this.status = Status.INACTIVE;
	}

	void update_message (Object[] content) {
		//this.message.clearArguments();

		//updates the evaluated objects to the osc message
		this.content = content;
	}

	//in this case, nothing is done
	void update_status() {
	}

	void update_ip (String ip) {
		this.ip = ip;
		this.broadcast = new NetAddress(ip, port);
	}

	void update_port (int port) {
		this.port = port;
		this.broadcast = new NetAddress(ip, port);
	}

	void update_message (String newMessage) {
		this.message = newMessage;
	}

	String build_string_from_content () {
		//formatting strings
		String param_text = "";
		for (int i = 0; i < content.length; i++) {
			if (i!=0) param_text += ", ";
			param_text += content[i].toString();
		}

		return param_text;
	}

	void update_content_from_string (String parameters) {
		//formatting strings
		String[] split = parameters.trim().split(",");
		Object[] result = new Object[split.length];

		//iterates over all the resulting strings
		for (int i = 0; i < split.length; i++)
			result[i] = new Expression(split[i]);

		content=result;
	}

}
