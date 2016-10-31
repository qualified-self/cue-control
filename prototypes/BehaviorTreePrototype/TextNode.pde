class TextNode extends BaseNode {

	String text;

	TextNode(String text)
	{
		super(text);
		this.text = text;
	}

	State doExecute(Blackboard agent)
	{
		println(agent.processExpression(text));
		return State.SUCCESS;
	}

	void doInit(Blackboard agent) {}

	String type() { return "TXT"; }
}
