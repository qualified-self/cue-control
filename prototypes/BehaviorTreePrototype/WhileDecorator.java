class WhileDecorator extends Decorator {

  // Condition for continuing.
  Condition condition;

  boolean running;

  State lastState;

  public WhileDecorator(String expression) {
    this(new ExpressionCondition(expression));
  }

  WhileDecorator(Condition condition) {
    this.condition = condition;
  }

  public void doInit(Blackboard agent) {
    super.doInit(agent);
    running = false;
  }

  public State doExecute(Blackboard agent) {
    if (!running)
    {
      if (condition.check(agent))
        running = true;
      else
      {
        scheduleInit();
        return State.SUCCESS; // default if no loop
      }
    }

    // Running.
    State status = node.doExecute(agent);

    if (status == State.SUCCESS) {
      node.scheduleInit();

      if (condition.check(agent))
        status = State.RUNNING;
      else
      {
        scheduleInit();
        status = State.SUCCESS;
      }
    }

    else if (status == State.FAILURE)
      node.scheduleInit();

    return status;
  }

  String getDefaultDescription() { return condition.toString(); }
}
