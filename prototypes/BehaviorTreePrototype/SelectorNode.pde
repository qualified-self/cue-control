class SelectorNode extends CompositeNode
{
  int currentPosition;
  boolean restart;

  SelectorNode(boolean restart) {
    this(null, restart);
  }

  SelectorNode(String description, boolean restart)
  {
    super(description);
    currentPosition = -1;
    this.restart = restart;
  }

  public State doExecute(Blackboard agent)
  {
    if (currentPosition == -1) //starting out
    {
      init(agent);
      currentPosition = 0;
    }
    else if (restart) // restart on running
    {
      currentPosition = 0;
    }

    if (nChildren() == 0)
      return State.SUCCESS;

    BaseNode currentlyRunningNode = children.get(currentPosition);
    State status;
    while ((status = currentlyRunningNode.execute(agent)) == State.FAILURE) //keep trying children until one doesn't fail
    {
      currentPosition++;
      if (currentPosition == nChildren()) //all of the children failed
      {
        currentPosition = -1;
        return State.FAILURE;
      } else
        currentlyRunningNode = children.get(currentPosition);
    }
    if (status == State.RUNNING)
      return State.RUNNING;
    else
    {
      currentPosition = -1;
      return State.SUCCESS;
    }
  }

  void doInit(Blackboard agent)
  {
    currentPosition = -1;
    for (BaseNode node : children)
      node.init(agent);
  }

  public String type() { return "SEL"; }
}
