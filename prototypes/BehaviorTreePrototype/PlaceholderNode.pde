class PlaceholderNode extends Decorator {

  String declaration;
  boolean useAsDecorator;

  PlaceholderNode() {
    reset();
  }

  void reset() {
    useAsDecorator = false;
    declaration = "";
  }

  Decorator setNode(BaseNode node) {
    super.setNode(node);
    useAsDecorator = true;
    return this;
  }

  void append(char k) {
    declaration += k;
  }

  void backspace() {
    if (declaration.length() >= 1)
      declaration = declaration.substring(0, declaration.length() - 1);
  }

  BaseNode submit() {
    BaseNode newNode = compile();
    if (newNode != null)
    {
      if (useAsDecorator)
        node.setDecorator((Decorator)newNode);
      else
        parent.replaceChild(this, newNode);
    }
    return newNode;
  }

  void cancel() {
    parent.removeChild(this);
  }

  BaseNode compile() {
    return factory.createNode(declaration, useAsDecorator);
  }

  String getDescription() { return declaration; }

  public State doExecute(Blackboard agent) { return State.UNDEFINED; }
  public void doInit(Blackboard agent) {}
  public String type() { return ""; }
}
