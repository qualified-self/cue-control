class PlaceholderNode extends BaseNode {

  String declaration;

  PlaceholderNode() {
    reset();
  }

  void reset() {
    declaration = "";
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
      parent.replaceChild(this, newNode);
    return newNode;
  }

  void cancel() {
    parent.removeChild(this);
  }

  BaseNode compile() {
    return factory.createNode(declaration);
  }

  String getDescription() { return declaration; }

  public State doExecute(Blackboard agent) { return State.UNDEFINED; }
  public void doInit(Blackboard agent) {}
  public String type() { return ""; }
}
