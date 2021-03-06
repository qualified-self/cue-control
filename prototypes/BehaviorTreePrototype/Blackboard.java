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

  void init() {
		for (BlackboardTask task : tasks)
			task.init(this);
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
      // Get value as string and process it.
      String stringValue = entry.getValue().toString();
      if (stringValue.equals(" "))
        stringValue = "' '";
      else if (stringValue.replaceAll(" ", "").isEmpty()) // ie. string is only whitespaces
        stringValue = "\"" + stringValue + "\"";
      else if (stringValue == null || stringValue.trim().isEmpty()) {
        stringValue = "null";
      }

      // Replace $varName by ${varName}.
      expr = expr.replaceAll("\\$" + entry.getKey() + "([^\\w]+)", "\\$\\{" + entry.getKey() + "\\}$1");

      // Replace ${varName} by actual value OR null if empty value.
      expr = expr.replaceAll("\\$\\{" + entry.getKey()+"\\}", stringValue);
    }

		return expr;
	}
}
