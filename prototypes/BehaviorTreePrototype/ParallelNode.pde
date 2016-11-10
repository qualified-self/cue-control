class ParallelNode extends CompositeNode
{
  boolean failOnAll;
  boolean succeedOnAll;

  ArrayList<Boolean> childrenRunning;
  int nFailure;
  int nSuccess;

  public ParallelNode() {
    this("");
  }

  public ParallelNode(boolean failOnAll, boolean succeedOnAll) {
    this("", failOnAll, succeedOnAll);
  }

  public ParallelNode(String description) {
    this(description, true, true);
  }

  public ParallelNode(String description, boolean failOnAll, boolean succeedOnAll)
  {
    super(description);
    this.failOnAll = failOnAll;
    this.succeedOnAll = succeedOnAll;
  }

  public State doExecute(Blackboard agent)
  {
    // This means init() wasn't called...
    if (childrenRunning == null || childrenRunning.size() != nChildren())
      init(agent);

    // go through all children and update the childrenRunning
    // TODO: implement avec ceci: https://github.com/NetEase/pomelo-bt/blob/master/lib/node/parallel.js
    for (int i = 0 ; i<nChildren(); i++)
    {
      if (childrenRunning.get(i).booleanValue())
      {
        State status = children.get(i).execute(agent);
        childrenRunning.set(i, new Boolean(status == State.RUNNING));

        if (status == State.SUCCESS)
          nSuccess++;
        else if (status == State.FAILURE)
          nFailure++;
      }
    }

    if (nSuccess == nChildren() || (!succeedOnAll && nSuccess >= 1))
    {
      init(agent);
      return State.SUCCESS;
    }
    else if (nFailure == nChildren() || (!failOnAll && nFailure >= 1))
    {
      init(agent);
      return State.FAILURE;
    }
    else
      return State.RUNNING;
  }

  void doInit(Blackboard agent)
  {
    childrenRunning = new ArrayList<Boolean>(nChildren());

    for (int i=0; i<nChildren(); i++) {
      children.get(i).init(agent);
      childrenRunning.add(new Boolean(true));
    }

    nSuccess = 0;
    nFailure = 0;
  }

  public String type() { return "PAR"; }
}
