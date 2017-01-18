/// Condition that triggers based on a boolean expression.
class ExpressionCondition extends Condition {

  Expression expression;

  ExpressionCondition(String expression) {
    this.expression = new Expression(expression);
  }

  boolean check(Blackboard agent) {
    try {
      return ((Boolean)expression.eval(agent)).booleanValue();
    }
    catch (Exception e) {
      Console.instance().error("Invalid expression: \"" + expression.toString() + "\".");
      Console.instance().error(e.getMessage());
      return false;
    }
  }

  public String toString() {
    return expression.toString();
  }
}
