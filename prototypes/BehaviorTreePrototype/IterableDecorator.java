import java.util.Iterator;

/// Decorator specialized for iterable composites.
abstract class IterableDecorator extends Decorator {

  IterableDecorator() {
    this((IterableNode)null);
  }

  IterableDecorator(IterableNode node) {
    super(node);
  }

  IterableDecorator setNode(IterableNode node) {
    super.setNode(node);
    return this;
  }

  IterableNode getNode() { return (IterableNode)super.getNode(); }

  public State doExecute(Blackboard agent) {
    if (hasNode())
      return node.doExecute(agent);
    else
      return State.SUCCESS;    
  }

  abstract Iterator<BaseNode> iterator();
}
