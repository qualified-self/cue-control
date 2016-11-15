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
    if (nChildren() == 0)
      return State.SUCCESS;

    BaseNode currentTask = children.get(currentPosition);
    State result = currentTask.execute(agent);

    while (result == State.SUCCESS)
    {
      if (currentPosition == nChildren()-1) //finished last task
      {
        return State.SUCCESS;
      }
      else
      {
        currentPosition++;
        currentTask = children.get(currentPosition);
        result = currentTask.execute(agent);
      }
    }

    // if (result == State.FAILURE)
    //   done();

    return result;
  }

  void doInit(Blackboard agent)
  {
    currentPosition = 0;
    for (BaseNode node : children)
      node.init(agent);
  }

  public String type() { return "SEQ"; }
}
