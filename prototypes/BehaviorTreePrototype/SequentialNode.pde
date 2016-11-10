class SequentialNode extends CompositeNode
{
  int currentPosition;

  public SequentialNode()
  {
    this(null);
  }

  public SequentialNode(String description)
  {
    super(description);
    currentPosition = -1;
  }

  public State doExecute(Blackboard agent)
  {
    if (currentPosition == -1) //starting out
    {
      init(agent);
      currentPosition = 0;
    }

    if (nChildren() == 0)
      return State.SUCCESS;

    BaseNode currentTask = children.get(currentPosition);
    State result = currentTask.execute(agent);

    while (result == State.SUCCESS)
    {
      if (currentPosition == nChildren()-1) //finished last task
      {
        currentPosition = -1; //indicate we are not running anything
        return State.SUCCESS;
      }
      else
      {
        currentPosition++;
        currentTask = children.get(currentPosition);
        result = currentTask.execute(agent);
      }
    }
    if (result == State.FAILURE)
      currentPosition = -1;
    return result;
  }

  void doInit(Blackboard agent)
  {
//    currentPosition = -1;
    for (BaseNode node : children)
      node.init(agent);
  }

  public String type() { return "SEQ"; }
}
