class Blackboard extends HashMap<String, Integer>
{
}

abstract class BaseNode
{
  State state = State.SUCCESS;
  String description;

  Decorator decorator;

  BaseNode()
  {
  }

  BaseNode(String description)
  {
    this.description = description;
  }

  public BaseNode setDecorator(Decorator decorator) {
    decorator.setNode(this);
    this.decorator = decorator;
    return this;
  }

  public boolean hasDecorator() { return decorator != null; }

  public Decorator getDecorator() { return decorator; }
  
  public void init(Blackboard agent) {
    if (hasDecorator())
      decorator.init(agent);
    else
      doInit(agent);
  }

  public State execute(Blackboard agent)
  {
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
