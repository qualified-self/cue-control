public class TextNode extends BaseNode {

	String text;

	public TextNode(String text)
	{
		super(text);
		this.text = text;
	}

	State doExecute(Blackboard agent)
	{
		Console.instance().log(agent.processExpression(text));
		return State.SUCCESS;
	}

	void doInit(Blackboard agent) {}
}
