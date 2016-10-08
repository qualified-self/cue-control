class BlackboardCondition extends Condition {

  String expression;

  ScriptEngineManager manager = new ScriptEngineManager();
  ScriptEngine engine = manager.getEngineByName("js");

  BlackboardCondition(String expression) {
    this.expression = expression;
  }

  boolean check(Blackboard agent) {
    String expr = expression;
    for (HashMap.Entry<String, Integer> element : agent.entrySet()) {
      expr = expr.replaceAll("\\["+element.getKey()+"\\]", element.getValue().toString());
    }

    println(expr);
    try {
      Boolean result = (Boolean)engine.eval(expr);
//      println("Result = " + result.booleanValue());
      return result.booleanValue();
    } catch (Exception e) {
      println("ERROR: " + e.toString());
      return false;
    }
  }

  public String toString() {
    return expression;
  }
}
