class Expression {

  String expression;

  ScriptEngineManager manager = new ScriptEngineManager();
  ScriptEngine engine = manager.getEngineByName("js");

  Expression(String expression) {
    this.expression = expression;
  }

	Object eval(Blackboard agent) {
    String expr = expression;
    for (HashMap.Entry<String, Integer> element : agent.entrySet()) {
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
