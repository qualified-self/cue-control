class SelectorNode extends CompositeNode 
{
  int currentPosition;
  boolean restart;

  SelectorNode(boolean restart) {
    this("", restart);
  }

  SelectorNode(String description, boolean restart)
  {
    super(description);
    currentPosition = -1;
    this.restart = restart;
  }

  public int doExecute(Blackboard agent)
  {
    if (currentPosition == -1) //starting out
    {
      init(agent);
      currentPosition = 0;
    } else if (restart) // restart on running
    {
      currentPosition = 0;
    }

    if (nChildren() == 0)
      return BT_SUCCESS;

    BaseNode currentlyRunningNode = children.get(currentPosition);
    int status;
    while ((status = currentlyRunningNode.execute(agent)) == BT_FAILURE) //keep trying children until one doesn't fail
    {
      currentPosition++;
      if (currentPosition == nChildren()) //all of the children failed
      {
        currentPosition = -1;
        return BT_FAILURE;
      } else
        currentlyRunningNode = children.get(currentPosition);
    }
    if (status == BT_RUNNING)
      return BT_RUNNING;
    else
    {
      currentPosition = -1;
      return BT_SUCCESS;
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