/// Blackboard class.
class Blackboard extends ConcurrentHashMap<String, Object>
{
	ArrayList<BlackboardTask> tasks;

	Blackboard() {
		tasks = new ArrayList<BlackboardTask>();
	}

	Blackboard addTask(BlackboardTask task)
	{
		tasks.add(task);
		return this;
	}

	void execute() {
		for (BlackboardTask task : tasks)
			task.execute(this);
	}

	/**
	 * Replaces variable names in expression with pattern "$varName" or "${varName}"
	 * with values corresponding to these variables from the blackboard.
	 */
	String processExpression(String expr) {
    expr += " "; // this is important for the regexp below

    // Iterate over every variable.
    for (Map.Entry<String, Object> entry : entrySet()) {
      // Replace $varName by ${varName}.
      expr = expr.replaceAll("\\$" + entry.getKey() + "([^\\w]+)", "\\$\\{" + entry.getKey() + "\\}$1");
      // Replace ${varName} by actual value.
      expr = expr.replaceAll("\\$\\{" + entry.getKey()+"\\}", entry.getValue().toString());
    }
    
		return expr;
	}
}
