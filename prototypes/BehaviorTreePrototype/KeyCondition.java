/// Condition that triggers when pressing a hotkey.
class KeyCondition extends Condition {

  char hotKey;

  KeyCondition(char hotKey) {
    this.hotKey = hotKey;
  }

  boolean check(Blackboard agent)
  {
    return (BehaviorTreePrototype.instance().keyPressed &&
            BehaviorTreePrototype.instance().key == hotKey);
  }

  public String toString() {
    return "PRESS '" + hotKey + "'";
  }
}
