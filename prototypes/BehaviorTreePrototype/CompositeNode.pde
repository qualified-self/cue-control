
abstract class CompositeNode extends BaseNode
{
  ArrayList<BaseNode> children;
  
  CompositeNode() {
    this("");
  }

  CompositeNode(String description) {
    super(description);
    children = new ArrayList<BaseNode>();
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