class Blackboard extends HashMap<String, Integer>
{
}

abstract class BaseNode 
{
  int state = BT_SUCCESS;
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
    println("set decorator");
    decorator.setNode(this);
    this.decorator = decorator;
    return this;
  }
  
  public boolean hasDecorator() { return decorator != null; }
  
  public void init(Blackboard agent) {
    if (hasDecorator())
      decorator.init(agent);
    else
      doInit(agent);
  }
  
  public int execute(Blackboard agent)
  {
    if (hasDecorator())
      state = decorator.execute(agent);
    else
      state = doExecute(agent);
    return state;
  }
  
  int getState() { return state; }
  String getDescription() { return (description == null ? getDefaultDescription() : description); }

  String getDefaultDescription() { return ""; }
  
  public abstract int doExecute(Blackboard agent);
  public abstract void doInit(Blackboard agent);
  public abstract String type();
}