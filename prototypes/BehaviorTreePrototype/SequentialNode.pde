class SequentialNode extends CompositeNode 
{
  int currentPosition;

  SequentialNode()
  {
    this("");
  }

  SequentialNode(String description)
  {
    super(description);
    currentPosition = -1;
  }

  public int doExecute(Blackboard agent)
  {
    if (currentPosition == -1) //starting out
    {
      init(agent);
      currentPosition = 0;
    }

    if (nChildren() == 0)
      return BT_SUCCESS;

    BaseNode currentTask = children.get(currentPosition);
    int result = currentTask.execute(agent);

    while (result == BT_SUCCESS)
    {
      if (currentPosition == nChildren()-1) //finished last task
      {
        currentPosition = -1; //indicate we are not running anything
        return BT_SUCCESS;
      } 
      else
      {
        currentPosition++;
        currentTask = children.get(currentPosition);
        result = currentTask.execute(agent);
      }
    }
    if (result == BT_FAILURE)
      currentPosition = -1;
    return result;
  }

  void doInit(Blackboard agent)
  {
    currentPosition = -1;
    for (BaseNode node : children)
      node.init(agent);
  }

  public String type() { return "SEQ"; }
}