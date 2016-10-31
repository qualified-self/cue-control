/// Blackboard class.
class Blackboard extends ConcurrentHashMap<String, Object>
{
	Pattern pattern1 = Pattern.compile("(\\$(\\w+))");
	Pattern pattern2 = Pattern.compile("(\\$\\{(\\w+)\\})"); //" <-- this comment to avoid code-highlight issues in Atom

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
		if (matcher.find())
		{
			String varName = matcher.group(2); // candidate var name in blackboard
			if (containsKey(varName))
				expr = matcher.replaceAll(get(varName).toString());
			else
				println("Blackboard variable not found: " + varName);
		}
		return expr;
	}

}
