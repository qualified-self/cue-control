class GuardDecorator extends Decorator {

  // Condition.
  Condition condition;

  boolean running;

  GuardDecorator(Condition condition) {
    this.condition = condition;
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
        return State.FAILURE;
    }

    // Running.
    State status = node.doExecute(agent);
    if (status != State.RUNNING)
      init(agent);
    return status;
  }
}
