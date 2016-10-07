class ParallelNode extends CompositeNode 
{
  boolean failOnAll;
  boolean succeedOnAll;
  
  ArrayList<Boolean> childrenRunning;
  int nFailure;
  int nSuccess;

  ParallelNode() {
    this("");
  }

  ParallelNode(boolean failOnAll, boolean succeedOnAll) {
    this("", failOnAll, succeedOnAll);
  }

  ParallelNode(String description) {
    this(description, true, true);
  }
  
  ParallelNode(String description, boolean failOnAll, boolean succeedOnAll)
  {
    super(description);
    this.failOnAll = failOnAll;
    this.succeedOnAll = succeedOnAll;
  }

  public int doExecute(Blackboard agent)
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
        int status = children.get(i).execute(agent);
        childrenRunning.set(i, new Boolean(status == BT_RUNNING));
  
        if (status == BT_SUCCESS)
          nSuccess++;
        else if (status == BT_FAILURE)
          nFailure++;
      }
    }
    
    if (nSuccess == nChildren() || (!succeedOnAll && nSuccess >= 1))
    {
      init(agent);
      return BT_SUCCESS;
    }
    else if (nFailure == nChildren() || (!failOnAll && nFailure >= 1))
    {
      init(agent);
      return BT_FAILURE;
    }
    else
      return BT_RUNNING;
  }

  void doInit(Blackboard agent)
  {
    childrenRunning = new ArrayList<Boolean>(nChildren());
    
    for (BaseNode node : children)
      node.init(agent);
    
    for (int i=0; i<nChildren(); i++) {
      children.get(i).init(agent);
      childrenRunning.add(new Boolean(true));
    }
    
    nSuccess = 0;
    nFailure = 0;
  }
  
  public String type() { return "PAR"; }
}