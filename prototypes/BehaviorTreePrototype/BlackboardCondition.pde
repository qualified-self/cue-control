class BlackboardCondition extends Condition {

  Expression expression;

  BlackboardCondition(String expression) {
    this.expression = new Expression(expression);
  }

  boolean check(Blackboard agent) {
    try {
      return ((Boolean)expression.eval(agent)).booleanValue();
    }
    catch (Exception e) {
      println("ERROR: " + e.toString());
      return false;
    }
  }

  public String toString() {
    return expression.toString();
  }
}
