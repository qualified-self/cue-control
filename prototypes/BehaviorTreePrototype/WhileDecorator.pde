class WhileDecorator extends Decorator {

  // Condition for continuing.
  Condition condition;

  boolean running;

  State lastState;

  WhileDecorator(String expression) {
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
        init(agent);
        return State.SUCCESS; // default if no loop
      }
    }

    // Running.
    State status = node.doExecute(agent);
    if (status == State.SUCCESS) {
      if (condition.check(agent))
        status = State.RUNNING;
      else
      {
        init(agent);
        status = State.SUCCESS;
      }
    }

    return status;
  }

  String getDefaultDescription() { return condition.toString(); }

  public String type() { return "WHL"; }
}
