import java.util.Iterator;

public abstract class IterableNode extends CompositeNode {

  transient Iterator<BaseNode> iterator;
  transient BaseNode current;

  IterableNode() {
    this("");
  }

  IterableNode(String description) {
    super(description);
    build();
  }

  void build() {
    current = null;
  }

  Iterator<BaseNode> iterator() {
    if (hasDecorator()) {
      Decorator decorator = getDecorator();
      /// XXX: this shows the limit of the approach of decoupling decorators.
      if (decorator instanceof IterableDecorator)
        return ((IterableDecorator)decorator).iterator();
    }

    return children.iterator(); // default
  }

  BaseNode current() {
    return current;
  }

  BaseNode next() {
    return (current = (iterator.hasNext() ? iterator.next() : null));
  }

  boolean hasNext() {
    return iterator.hasNext();
  }

  void reset() {
    iterator = iterator();
    next();
  }

  void doInit(Blackboard agent)
  {
    reset();
    for (BaseNode node : children)
      node.init(agent);
  }

}
