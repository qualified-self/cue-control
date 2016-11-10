/// Blackboard class.
class Blackboard extends ConcurrentHashMap<String, Object>
{
	Pattern pattern1 = Pattern.compile("(\\$(\\w+))");
	Pattern pattern2 = Pattern.compile("(\\$\\{(\\w+)\\})"); //" <-- this comment to avoid code-highlight issues in Atom

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
		expr = _processPattern(pattern1, expr);
		expr = _processPattern(pattern2, expr);
		return expr;
	}

	String _processPattern(Pattern pattern, String expr) {
		Matcher matcher = pattern.matcher(expr);
		while (matcher.find())
		{
  	  String varName = matcher.group(2); // candidate var name in blackboard
  		if (containsKey(varName))
      {
  			expr = matcher.replaceFirst(get(varName).toString());
        matcher = pattern.matcher(expr);
      }
  		else
  			println("Blackboard variable not found: " + varName);
		}
		return expr;
	}

}
