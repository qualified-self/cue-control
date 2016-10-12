class Expression {

  String expression;

  ScriptEngineManager manager = new ScriptEngineManager();
  ScriptEngine engine = manager.getEngineByName("js");

  Expression(String expression) {
    this.expression = expression;

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
