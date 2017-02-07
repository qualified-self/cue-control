import java.util.ArrayList;

public abstract class CompositeNode extends BaseNode
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
    build();
  }

  void build() {
    super.build();
    if (children != null) {
      for (BaseNode node : children)
        node.build();
    }
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

  CompositeNode setDecorator(Decorator decorator) {
    return (CompositeNode)super.setDecorator(decorator);
  }

  int indexOf(BaseNode node) {
    return children.indexOf(node);
  }

  CompositeNode addChild(BaseNode node) {
    children.add(node);
    node.setParent(this);
    needsInit = true;
    return this;
  }

  CompositeNode insertChild(BaseNode after, BaseNode node) {
    children.add(after == null ? 0 : children.indexOf(after)+1, node);
    node.setParent(this);
    needsInit = true;
    return this;
  }

  CompositeNode removeChild(BaseNode node) {
    children.remove(node);
    node.removeParent();
    needsInit = true;
    return this;
  }

  CompositeNode moveChild(int from, int to) {
    BaseNode node = children.get(from);
    children.remove(from);
    children.add(to, node);
    needsInit = true;
    return this;
  }

  CompositeNode replaceChild(BaseNode from, BaseNode to) {
    children.set(children.indexOf(from), to);
    from.removeParent();
    to.setParent(this);
    needsInit = true;
    return this;
  }

  BaseNode getChild(int index) {
    return children.get(index);
  }

  ArrayList<BaseNode> getChildren() { return children; }
  ArrayList<BaseNode> getEnabledChildren() {
    ArrayList<BaseNode> enabledChildren = new ArrayList<BaseNode>();
    for (BaseNode child : children)
      if (child.isEnabled())
        enabledChildren.add(child);
    return enabledChildren;
  }
  // CompositeNode insertChild(... )

  int nChildren() { return children.size(); }
  int nEnabledChildren() { return getEnabledChildren().size(); }

  State execute(Blackboard agent)
  {
    State state = super.execute(agent);

    // If parent has stopped, stop any running children.
    if (state != State.RUNNING) {
      for (BaseNode node : getEnabledChildren())
        if (node.getState() == State.RUNNING)
          node.init(agent);
    }

    return state;
  }

  void setPlayState(boolean playing) {
    super.setPlayState(playing);
    for (BaseNode c : children)
      c.setPlayState(playing);
  }
}
