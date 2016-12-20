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

  public abstract State doExecute(Blackboard agent);
  public void doInit(Blackboard agent) {
//    BehaviorTreePrototype.instance().println("Decorator do-init");
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

  String baseName() {
    String basename = getClass().getSimpleName();
    return basename.substring(0, basename.length() - "Decorator".length());
  }
}
