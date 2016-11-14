class ConditionBlackboardTask extends BlackboardTask
{
	String varName;
	Condition condition;

	ConditionBlackboardTask(String varName, Condition condition)
	{
		this.varName = varName;
		this.condition = condition;
	}

	void execute(Blackboard agent)
	{
		agent.put(varName, new Boolean(condition.check(agent)));
	}
}
