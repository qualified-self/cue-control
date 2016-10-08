/*class ConditionDecorator extends Decorator {

  // Condition.
  Condition condition;

  // Status to return on false.
  int statusOnFalse;

  // Repeat or check only once.
  boolean checkOnce;
  
  //
  int checkOnceStatus;

  final int CHECK_ONCE_NOT_CHECKED = 0;
  final int CHECK_ONCE_TRUE        = 1;
  final int CHECK_ONCE_FALSE       = 2;

  ConditionDecorator(Condition condition) {
    this(condition, true, State.FAILURE);
  }

  ConditionDecorator(Condition condition, boolean checkOnce) {
    this(condition, checkOnce, State.FAILURE);
  }

  ConditionDecorator(Condition condition, boolean checkOnce, int statusOnFalse) {
    this.condition = condition;
    this.statusOnFalse = statusOnFalse;
    checkOnceStatus = CHECK_ONCE_NOT_CHECKED;
  }

  public void init(Blackboard agent) {
    super.init(agent);
    checkOnceStatus = CHECK_ONCE_NOT_CHECKED;
  }

  public State execute(Blackboard agent) {
    if (checkOnce) {
      if (checkOnceStatus == CHECK_ONCE_NOT_CHECKED) {
        checkOnceStatus = condition.check(agent) ? CHECK_ONCE_TRUE : CHECK_ONCE_FALSE;
      }

      if (checkOnceStatus == CHECK_ONCE_TRUE)
      node.doInit(agent);
        return node.doExecute(agent);
      else {
        init(agent);
        return statusOnFalse;
      }
    }

    else
      if (condition.check(agent))
        return node.doExecute(agent) : statusOnFalse);
  }
}*/
