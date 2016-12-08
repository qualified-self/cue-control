class ConstantCondition extends Condition {

  static final ConstantCondition TRUE  = new ConstantCondition(true);
  static final ConstantCondition FALSE = new ConstantCondition(false);

  boolean value;

  ConstantCondition(boolean value) {
    this.value = value;
  }

  boolean check(Blackboard agent) {
    return value;
  }

  public String toString() {
    return new Boolean(value).toString();
  }
}
