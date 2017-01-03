/************************************************
************************************************
** implementing a task for setting the blackboard
************************************************
************************************************/

class SetBBTask extends Task {

  Object value;

  public SetBBTask (PApplet p, String taskname, Object value) {
    super(p, taskname);
    this.value = value;
  }

  SetBBTask clone() {
    return new SetBBTask(this.p, this.name, this.value);
  }

  void run() {
    this.status = Status.RUNNING;
    bb.put(name, evaluate_value(value));
    this.status = Status.DONE;
  }

  void stop() {
    this.status = Status.INACTIVE;
  }

  void update_value(Object new_value) {
    value = new_value;
  }

  void update_status() {
  }

}
