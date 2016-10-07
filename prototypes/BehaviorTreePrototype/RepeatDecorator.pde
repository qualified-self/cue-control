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

  public int doExecute(Blackboard agent) {
    boolean check = condition.check(agent);
    if (!running) {
      if (check)
        running = true;
      else
        return BT_FAILURE;
    }
    
    // Running.
    int status = node.doExecute(agent);
    if (status != BT_RUNNING) {
      init(agent);
      if (check && status == BT_SUCCESS)
        return BT_RUNNING; // repeat
    }
    return status;
  }
}