class CueNode extends BaseNode {
  float preWait;
  float postWait;
  float runningTime;

  Chrono chrono;

  int step;

  CueNode(String description, float preWait, float runningTime, float postWait) {
    super(description);
    this.preWait     = preWait;
    this.runningTime = runningTime;
    this.postWait    = postWait;
    chrono = new Chrono(false);
   }

  float getPreWait()     { return this.preWait; }
  float getPostWait()    { return this.postWait; }
  float getRunningTime() { return this.runningTime; }

  boolean isInPreWait() {
    return currentTime() < preWait;
  }

  boolean isInRun() {
    return !isInPreWait() && currentTime() < preWait+runningTime;
  }

  boolean isInPostWait() {
    return !isInRun() && currentTime() < preWait+runningTime+postWait;
  }

  boolean hasEnded() {
    return currentTime() >= preWait + runningTime + postWait;
  }

  boolean beginCue(Blackboard agent) {
    if (step == 0) {
      if (!doBeginCue(agent))
        return false;
      step = 1;
    }
    else
      println("Wrong step to call beginCue(): " + step);

    return true;
  }

  boolean runCue(Blackboard agent) {
    if (step == 0)
      if (!beginCue(agent))
        return false;

    if (step == 1) {
      if (!doRunCue(agent))
        return false;

      step = 2;
    }

    return true;
  }

  boolean endCue(Blackboard agent) {
    if (step <= 1)
      if (!runCue(agent))
        return false;

    if (step == 2) {
      if (!doEndCue(agent))
        return false;
      step = 3;
    }

    return true;
  }

  boolean doBeginCue(Blackboard agent) { return true; }
  boolean doRunCue(Blackboard agent) { return true; }
  boolean doEndCue(Blackboard agent) { return true; }

  boolean result(Blackboard agent) { return true; }


  public State doExecute(Blackboard agent)
  {
    if (!chrono.isRunning()) {
      chrono.restart();
      step = 0;
    }

    if (isInRun())
    {
      if (!runCue(agent)) // this will also call beginCue if needed
      {
        init(agent);
        return State.FAILURE;
      }
    }
    else if ((isInPostWait() || hasEnded()) && step != 2)
    {
      if (!endCue(agent))
      {
        init(agent);
        return State.FAILURE;
      }
    }

    if (hasEnded()) {
      State status = (result(agent) ? State.SUCCESS : State.FAILURE);
      init(agent);
      return status;
    }
    else
      return State.RUNNING;
 //     return (hasEnded() ? (succeeds ? State.SUCCESS : State.FAILURE) : State.RUNNING);
  }

  public void doInit(Blackboard agent)
  {
    chrono.stop();
  }

  public String type() { return "CUE"; }

  float currentTime() {
    return (chrono.elapsed())/1000.0f;
  }

}
