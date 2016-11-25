/************************************************
************************************************
** implementing a task for setting the blackboard
************************************************
************************************************/

class SetBBTask extends Task {

  Object value;

  public SetBBTask (String taskname, Object value) {
    super(taskname);
    this.value = value;
  }

  /*
  public SetBBTask (PApplet p, String taskname, Object value) {
    super(p, taskname);
    this.value = value;
  }
  */

  SetBBTask clone() {
    return new SetBBTask(this.name, this.value);
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

  Group load_gui_elements(State s) {
    Group g = cp5.addGroup(s.name + " " + this.get_name())
      .setColorBackground(color(255, 50)) //color of the task
      .setBackgroundColor(color(255, 25)) //color of task when openned
      .setBackgroundHeight(90)
      .setLabel(this.get_prefix() + "   " + this.get_name())
      .setHeight(12)
    ;

  g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  int localx = 10, localy = 15, localoffset = 40;
  int w = g.getWidth()-10;

  cp5.addTextfield("name")
    .setPosition(localx, localy)
    .setSize(w, 15)
    .setGroup(g)
    .setAutoClear(false)
    .setLabel("name")
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
  ;

  cp5.addTextfield("value")
    .setPosition(localx, localy+localoffset)
    .setSize(w, 15)
    .setGroup(g)
    .setAutoClear(false)
    .setLabel("value")
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    ;

    return g;
  }

}
