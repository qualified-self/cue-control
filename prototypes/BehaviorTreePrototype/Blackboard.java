import java.util.concurrent.ConcurrentHashMap;
import java.util.ArrayList;
import java.util.Map;
import java.io.Serializable;

/// Blackboard class.
public class Blackboard extends ConcurrentHashMap<String, Object> implements Serializable
{
	ArrayList<BlackboardTask> tasks;

	Blackboard() {
		tasks = new ArrayList<BlackboardTask>();
	}

  void build() {
		for (BlackboardTask task : tasks)
			task.build();
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
