abstract class Decorator extends BaseNode {
  // Decorated node.
  BaseNode node;
  
  Decorator() {
    this((BaseNode)null);
  }
  
  Decorator(BaseNode node) {
    super();
    this.node = node;
  }

  public abstract int doExecute(Blackboard agent);
  public void doInit(Blackboard agent) {
    if (hasNode())
      node.doInit(agent);
  }

  Decorator setNode(BaseNode node) {
    this.node = node;
    return this;
  }
  
  boolean hasNode() {
    return node != null;
  }
  
  BaseNode getNode() { return node; }
  
  public String type() { return "DEC"; }

}