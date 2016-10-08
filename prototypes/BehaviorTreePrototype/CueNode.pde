class CueNode extends BaseNode {
  float preWait;
  float postWait;
  float runningTime;

  int startTime;

  CueNode(String description, float preWait, float runningTime, float postWait) {
    super(description);
    this.preWait     = preWait;
    this.runningTime = runningTime;
    this.postWait    = postWait;
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

  void beginCue(Blackboard agent) {}
  void runCue(Blackboard agent) {}
  void endCue(Blackboard agent) {}

  boolean result(Blackboard agent) { return true; }

  boolean preWaiting = false;
  boolean postWaiting = false;

  public State doExecute(Blackboard agent)
  {
    if (startTime == -1) {
      startTime = millis();
      preWaiting = true;
      postWaiting = true;
    }

    if (isInRun())
    {
      if (preWaiting) {
        beginCue(agent);
        preWaiting = false;
      }
      else
        runCue(agent);
    }
    else if (isInPostWait()) {
      if (postWaiting) {
        endCue(agent);
        postWaiting = false;
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
    startTime = -1;
  }

  public String type() { return "CUE"; }

  float currentTime() {
    return (millis() - startTime)/1000.0f;
  }

}
