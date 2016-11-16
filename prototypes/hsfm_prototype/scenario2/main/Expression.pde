
/************************************************
 ** Class used to interpret expressions developed by Sofian
 ************************************************/

// Static components.
ScriptEngineManager manager;
ScriptEngine engine;

/// Expression class which allows to compute javascript-style expressions with variables from the blackboard.
class Expression {

  String expression;

  public Expression(String expression) {

    this.expression = expression;

    if (manager == null) {
      manager = new ScriptEngineManager();
      engine = manager.getEngineByName("js");
      try {
        // Load library for math operations.
        java.util.Scanner s = new java.util.Scanner(new java.net.URL("file://" + dataPath("math.js")).openStream()).useDelimiter("\\A");
        engine.eval(s.hasNext() ? s.next() : "");
      }
      catch (Exception e) {
        println(e);
      }
    }
  }

  /// Computes expression using blackboard and returns result.
	Object eval(Blackboard agent) throws ScriptException {
    return engine.eval(agent.processExpression(expression));
	}

  public String toString() {
    return expression;
  }

}
