
abstract class CompositeNode extends BaseNode
{
  ArrayList<BaseNode> children;

  // This is GUI pollution: it should be moved somewhere else but for the prototype
  // let's keep it here.
  boolean expanded;

  CompositeNode() {
    this("");
  }

  CompositeNode(String description) {
    super(description);
    children = new ArrayList<BaseNode>();
    expanded = true;
  }

  CompositeNode setExpanded(boolean expanded) {
    this.expanded = expanded;
    return this;
  }

  boolean isExpanded() {
    return expanded;
  }

  void toggleExpanded() {
    expanded = !expanded;
  }

  public CompositeNode setDecorator(Decorator decorator) {
    return (CompositeNode)super.setDecorator(decorator);
  }

  CompositeNode addChild(BaseNode node) {
    children.add(node);
    return this;
  }

  int nChildren() { return children.size(); }
}
