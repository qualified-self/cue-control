import javax.script.*;

/// Expression class which allows to compute javascript-style expressions with variables from the blackboard.
class Expression {

// Static components.
  static ScriptEngineManager manager;
  static ScriptEngine engine;

  Object expression;

  Expression(Object expression) {
    this.expression = expression;
    if (manager == null) {
      manager = new ScriptEngineManager();
      engine = manager.getEngineByName("js");
      try {
        // Load library for math operations.
        String mathFilePath = BehaviorTreePrototype.instance().dataPath("math.js");
        java.util.Scanner s = new java.util.Scanner(new java.net.URL("file://" + mathFilePath).openStream()).useDelimiter("\\A");
        engine.eval(s.hasNext() ? s.next() : "");
      }
      catch (Exception e) {
        System.out.println(e);
      }
    }
  }

  /// Computes expression using blackboard and returns result.
	Object eval(Blackboard agent) throws ScriptException {
    if (expression instanceof String)
      return engine.eval(agent.processExpression((String)expression));
    else
      return expression;
	}

  /// Eval without agent.
  Object eval() throws ScriptException {
    if (expression instanceof String)
      return engine.eval((String)expression);
    else
      return expression;
	}

  public String toString() {
    return expression.toString();
  }

}
