import java.io.Serializable;

public abstract class BaseNode implements Serializable
{
  transient State state = State.SUCCESS;

  String description;

  Decorator decorator;

  transient boolean needsInit;

  CompositeNode parent;

  BaseNode()
  {
    this(null);
  }

  BaseNode(String description)
  {
    this.parent = null;
    this.description = description;
    build();
  }

  void build() {
    state = State.UNDEFINED;
    needsInit = true;
  }

  BaseNode setDecorator(Decorator decorator) {
    decorator.setNode(this);
    this.decorator = decorator;
    needsInit = true;
    return this;
  }

  boolean hasDecorator() { return decorator != null; }

  Decorator getDecorator() { return decorator; }

  void removeParent() {
    parent = null;
  }

  BaseNode setParent(CompositeNode parent) {
    if (hasParent()) {
//      System.out.println("Cannot set parent: already has one. Remove it first.");
      new Exception().printStackTrace();
    }
    else
      this.parent = parent;
    return this;
  }

  boolean hasParent() { return parent != null; }

  CompositeNode getParent() { return parent; }

  void init(Blackboard agent) {
    needsInit = false;
    if (hasDecorator())
      decorator.init(agent);
    else
      doInit(agent);

    // Reset previous state.
    state = State.UNDEFINED;
  }

  State execute(Blackboard agent)
  {
    if (needsInit) {
      init(agent);
    }
    if (hasDecorator())
      state = decorator.execute(agent);
    else
      state = doExecute(agent);
    return state;
  }

  State getState() { return state; }
  String getDescription() { return (description == null ? getDefaultDescription() : description); }

  String getDefaultDescription() { return ""; }

  abstract State doExecute(Blackboard agent);
  abstract void doInit(Blackboard agent);
  abstract String type();
}
