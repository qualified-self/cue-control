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

  void beginCue(Blackboard agent) {
    if (step == 0) {
      doBeginCue(agent);
      step = 1;
    }
    else
      println("Wrong step to call beginCue(): " + step);
  }

  void runCue(Blackboard agent) {
    if (step == 0)
      beginCue(agent);
    if (step == 1) {
      doRunCue(agent);
      step = 2;
    }
  }

  void endCue(Blackboard agent) {
    if (step <= 1)
      runCue(agent);
    if (step == 2) {
      doEndCue(agent);
      step = 3;
    }
  }

  void doBeginCue(Blackboard agent) {}
  void doRunCue(Blackboard agent) {}
  void doEndCue(Blackboard agent) {}

  boolean result(Blackboard agent) { return true; }


  public State doExecute(Blackboard agent)
  {
    if (!chrono.isRunning()) {
      chrono.restart();
      step = 0;
    }

    if (isInRun())
      runCue(agent); // this will also call beginCue if needed
    else if ((isInPostWait() || hasEnded()) && step != 2)
       endCue(agent);

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
