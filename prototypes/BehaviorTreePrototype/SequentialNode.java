class SequentialNode extends IterableNode
{

  public SequentialNode()
  {
    this(null);
  }

  public SequentialNode(String description)
  {
    super(description);
  }

  public State doExecute(Blackboard agent)
  {
    if (nChildren() == 0)
      return State.SUCCESS;

//    BaseNode currentTask = children.get(currentPosition);
    State result = current().execute(agent);

    while (result == State.SUCCESS)
    {
      if (!hasNext()) //finished last task
      {
        return State.SUCCESS;
      }
      else
      {
        result = next().execute(agent);
      }
    }

    // if (result == State.FAILURE)
    //   done();

    return result;
  }

}
