class WhileDecorator extends Decorator {

  // Condition.
  Condition condition;

  boolean running;

  WhileDecorator(Condition condition) {
    this.condition = condition;
  }

  public void doInit(Blackboard agent) {
    super.doInit(agent);
    running = false;
  }

  public State doExecute(Blackboard agent) {
    boolean check = condition.check(agent);
    if (!running) {
      if (check)
        running = true;
      else
        return State.FAILURE;
    }
    
    // Running.
    State status = node.doExecute(agent);
    if (status != State.RUNNING) {
      init(agent);
      if (check && status == State.SUCCESS)
        return State.RUNNING; // repeat
    }
    return status;
  }
}
