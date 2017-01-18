class PlaceholderNode extends Decorator {

  String declaration;
  boolean useAsDecorator;

  PlaceholderNode() {
    reset();
  }

  boolean isDecorator() {
    return useAsDecorator;
  }

  Decorator setNode(BaseNode node) {
    super.setNode(node);
    useAsDecorator = true;
    return this;
  }

  void reset() {
    useAsDecorator = false;
    declaration = "";
  }

  void append(char k) {
    declaration += k;
  }

  void assign(String dec) {
    declaration = dec;
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
    if (useAsDecorator)
      node.removeDecorator();
    else
      parent.removeChild(this);
  }

  BaseNode compile() {
    return factory.createNode(declaration, useAsDecorator);
  }

  String getDescription() { return declaration; }

  // Node type is just the first part of the string before the first space.
  String getNodeType() { return getDescription().replaceAll(" .*", ""); }

  public State doExecute(Blackboard agent) { return State.UNDEFINED; }
  public void doInit(Blackboard agent) {}
  public String type() { return ""; }
}
