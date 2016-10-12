// Static components.
final String MATHJS_URL = "http://cdnjs.cloudflare.com/ajax/libs/mathjs/1.0.1/math.js"; // math library
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
        java.util.Scanner s = new java.util.Scanner(new java.net.URL(MATHJS_URL).openStream()).useDelimiter("\\A");
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
    String expr = expression;
    // Replace keys from the blackboard.
    for (HashMap.Entry<String, Double> element : agent.entrySet()) {
      expr = expr.replaceAll("\\["+element.getKey()+"\\]", element.getValue().toString());
    }
    try {
      return engine.eval(expr);
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
