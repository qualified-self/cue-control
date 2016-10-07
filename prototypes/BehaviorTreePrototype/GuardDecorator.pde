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

  public int doExecute(Blackboard agent) {
    if (!running) {
      if (condition.check(agent))
        running = true;
      else
        return BT_FAILURE;
    }

    // Running.
    int status = node.doExecute(agent);
    if (status != BT_RUNNING)
      init(agent);
    return status;
  }
}