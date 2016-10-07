class KeyCondition extends Condition {
  
  char hotKey;
  
  KeyCondition(char hotKey) {
    this.hotKey = hotKey;
  }
  
  boolean check(Blackboard agent)
  {
    return (keyPressed && key == hotKey);
  }
  
}