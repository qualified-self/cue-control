public class TextNode extends BaseNode {

	Expression text;

	public TextNode(Object expression)
	{
		super(expression.toString());
		this.text = new Expression(expression);
	}

	State doExecute(Blackboard agent)
	{
		try {
			Console.instance().log(text.eval(agent));
		} catch (Exception e) {
      Console.instance().error(e.getMessage());
			return State.FAILURE;
		}
		return State.SUCCESS;
	}

	void doInit(Blackboard agent) {}
}
