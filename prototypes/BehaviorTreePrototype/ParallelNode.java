import java.util.ArrayList;

class ParallelNode extends CompositeNode
{
  boolean sequencePolicy;

  ArrayList<Boolean> childrenRunning;
  int nFailure;
  int nSuccess;

  public ParallelNode() {
    this("");
  }

  public ParallelNode(boolean sequencePolicy) {
    this(sequencePolicy ? "sequence" : "selector" + " policy", sequencePolicy);
  }

  public ParallelNode(String description) {
    this(description, true);
  }

  public ParallelNode(String description, boolean sequencePolicy)
  {
    super(description);
    this.sequencePolicy = sequencePolicy;
  }

  public State doExecute(Blackboard agent)
  {
    // // This means init() wasn't called...
    // if (childrenRunning == null || childrenRunning.size() != nChildren())
    //   init(agent);

    // go through all children and update the childrenRunning
    // TODO: implement avec ceci: https://github.com/NetEase/pomelo-bt/blob/master/lib/node/parallel.js
    for (int i = 0; i<nChildren(); i++)
    {
//      BehaviorTreePrototype.instance().println("processing " + childrenRunning);
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

    if (nFailure == nChildren() || (sequencePolicy && nFailure >= 1))
    {
//      childrenRunning = null;
      return State.FAILURE;
    }
    else if (nSuccess == nChildren() || (!sequencePolicy && nSuccess >= 1))
    {
//      childrenRunning = null;
      return State.SUCCESS;
    }
    else
      return State.RUNNING;
  }

  void doInit(Blackboard agent)
  {
//    BehaviorTreePrototype.instance().println("do init par for " + nChildren());
    childrenRunning = new ArrayList<Boolean>(nChildren());

    for (int i=0; i<nChildren(); i++) {
//      BehaviorTreePrototype.instance().println("init on kid " + i);
      children.get(i).init(agent);
      childrenRunning.add(new Boolean(true));
    }

    nSuccess = 0;
    nFailure = 0;
  }
}
