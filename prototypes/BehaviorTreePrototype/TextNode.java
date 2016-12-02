public class TextNode extends BaseNode {

	String text;

	TextNode(String text)
	{
		super(text);
		this.text = text;
	}

	State doExecute(Blackboard agent)
	{
		System.out.println(agent.processExpression(text));
		return State.SUCCESS;
	}

	void doInit(Blackboard agent) {}
}
