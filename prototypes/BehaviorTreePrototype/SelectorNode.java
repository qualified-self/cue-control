public class SelectorNode extends IterableNode
{
  int currentPosition;
  boolean restart;

  public SelectorNode() {
    this(null, false);
  }

  public SelectorNode(boolean restart) {
    this(restart ? "restart" : "no-restart", restart);
  }

  public SelectorNode(String description)
  {
    this(description, false);
  }

  public SelectorNode(String description, boolean restart)
  {
    super(description);
    this.restart = restart;
  }

  public State doExecute(Blackboard agent)
  {
    if (nChildren() == 0)
      return State.SUCCESS;

    // if (currentPosition == -1) //starting out
    // {
    //   init(agent);
    //   currentPosition = 0;
    // }
    // else
    if (restart) // restart on running
    {
      reset();
    }

    State status;
    while ((status = current().execute(agent)) == State.FAILURE) //keep trying children until one doesn't fail
    {
      if (!hasNext()) //all of the children failed
      {
        //currentPosition = -1;
        return State.FAILURE;
      }
      else
        next();
    }

    if (status == State.RUNNING)
      return State.RUNNING;
    else
    {
//      currentPosition = -1;
      return State.SUCCESS;
    }
  }

}
