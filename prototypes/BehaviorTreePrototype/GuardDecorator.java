class GuardDecorator extends Decorator {

  // Condition.
  Condition condition;

  boolean running;

  // If true, will return SUCCESS in case the condition fails.
  boolean succeedOnFalse;

  GuardDecorator(String expression) {
    this(new ExpressionCondition(expression));
  }

  GuardDecorator(String expression, boolean succeedOnFalse) {
    this(new ExpressionCondition(expression), succeedOnFalse);
  }

  GuardDecorator(Condition condition) {
    this(condition, false);
  }

  GuardDecorator(Condition condition, boolean succeedOnFalse) {
    this.condition = condition;
    this.succeedOnFalse = succeedOnFalse;
  }

  public void doInit(Blackboard agent) {
    super.doInit(agent);
    running = false;
  }

  public State doExecute(Blackboard agent) {
    if (!running) {
      if (condition.check(agent))
        running = true;
      else
        return (succeedOnFalse ? State.SUCCESS : State.FAILURE);
    }

    // Running.
    State status = node.doExecute(agent);
    if (status != State.RUNNING)
      node.scheduleInit();

    return status;
  }

  String getDefaultDescription() { return condition.toString(); }

}
