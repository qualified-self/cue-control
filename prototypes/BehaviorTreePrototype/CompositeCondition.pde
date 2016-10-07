class OrCondition extends Condition {
  Condition a, b;
  OrCondition(Condition a, Condition b) {
    this.a = a;
    this.b = b;
  }
  boolean check(Blackboard agent) {
    return a.check(agent) || b.check(agent);
  }
}

class AndCondition extends Condition  {
  Condition a, b;
  AndCondition(Condition a, Condition b) {
    this.a = a;
    this.b = b;
  }
  boolean check(Blackboard agent) {
    return a.check(agent) && b.check(agent);
  }
}

class NotCondition extends Condition  {
  Condition a;
  NotCondition(Condition a) {
    this.a = a;
  }

  boolean check(Blackboard agent) {
    return !a.check(agent);
  }
}  
  