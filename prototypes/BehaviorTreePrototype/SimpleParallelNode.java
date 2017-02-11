class SimpleParallelNode extends CompositeNode
{
  public SimpleParallelNode() {
    this("");
  }

  public SimpleParallelNode(String description) {
    super(description);
  }

  public State doExecute(Blackboard agent)
  {
    if (nChildren() == 0)
      return State.SUCCESS;

    // // This means init() wasn't called...
    // if (childrenRunning == null || childrenRunning.size() != nChildren())
    //   init(agent);

    // go through all children and update the childrenRunning
    // TODO: implement avec ceci: https://github.com/NetEase/pomelo-bt/blob/master/lib/node/parallel.js
		boolean firstSucceeded = false;
    for (int i = 0; i<nChildren(); i++)
    {
      State status = children.get(i).execute(agent);

      if (status == State.FAILURE)
        return State.FAILURE;
      // NOTE: as soon as main children stops, let everyone run one last time and then stop.
      else if (i == 0 && status == State.SUCCESS)
        firstSucceeded = true;
    }

		return (firstSucceeded ? State.SUCCESS : State.RUNNING);
  }

  void doInit(Blackboard agent)
  {
    for (BaseNode node : children)
      node.init(agent);
  }
}
