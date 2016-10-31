// Static components.
ScriptEngineManager manager;
ScriptEngine engine;

class Expression {

  String expression;

  Expression(String expression) {
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

  Double evalAsDouble(Blackboard agent) {
    return new Double( ((Number)eval(agent)).doubleValue() );
  }

	Object eval(Blackboard agent) {
    try {
      return engine.eval(agent.processExpression(expression));
    }
		catch (Exception e) {
      println("ERROR: " + e.toString());
			return null;
    }
	}

  public String toString() {
    return expression;
  }

}
