
abstract class BaseNode
{
  State state = State.SUCCESS;
  String description;

  Decorator decorator;

  boolean needsInit;

  CompositeNode parent;

  BaseNode()
  {
    this(null);
  }

  BaseNode(String description)
  {
    this.parent = null;
    this.description = description;
    state = State.UNDEFINED;
    needsInit = true;
  }

  public BaseNode setDecorator(Decorator decorator) {
    decorator.setNode(this);
    this.decorator = decorator;
    needsInit = true;
    return this;
  }

  public boolean hasDecorator() { return decorator != null; }

  public Decorator getDecorator() { return decorator; }

  public void removeParent() {
    parent = null;
  }

  public BaseNode setParent(CompositeNode parent) {
    if (hasParent()) {
      println("Cannot set parent: already has one. Remove it first.");
    }
    else
      this.parent = parent;
    return this;
  }

  public boolean hasParent() { return parent != null; }

  public CompositeNode getParent() { return parent; }

  public void init(Blackboard agent) {
    needsInit = false;
    if (hasDecorator())
      decorator.init(agent);
    else
      doInit(agent);

    // Reset previous state.
    state = State.UNDEFINED;
  }

  public State execute(Blackboard agent)
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

  public abstract State doExecute(Blackboard agent);
  public abstract void doInit(Blackboard agent);
  public abstract String type();
}
