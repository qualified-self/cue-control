/************************************************
************************************************
** implementing a task for setting the blackboard
************************************************
************************************************/

class SetBBTask extends Task {

  Object value;
  String variableName;

  public SetBBTask (String taskname, Object value) {
    super(taskname);
    this.variableName = taskname;
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
    bb.put(variableName, evaluate_value(value));
    this.status = Status.DONE;
  }

  void stop() {
    this.status = Status.INACTIVE;
  }

  void update_value(Object new_value) {
    value = new_value;
  }

  void update_variable_name(String newname) {
    this.variableName = newname;
  }

  void update_status() {
  }

  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {

          String s = theEvent.getController().getName();
          //println(s + " was entered");

          if (s.equals(get_gui_id() + "/name")) {
              String text = theEvent.getController().getValueLabel().getText();
              update_variable_name(text);
              println(s + " " + text);
          }
          if (s.equals(get_gui_id() + "/value")) {
              String newvalue = theEvent.getController().getValueLabel().getText();
              update_value(new Expression(newvalue));
              println(s + " " + newvalue);
          }
        }
    };
  }

    CallbackListener generate_callback_leave() {
      return new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {

          String s = theEvent.getController().getName();

          String newtext = theEvent.getController().getValueLabel().getText();
          String oldtext = "";

          if (s.equals(get_gui_id() + "/name"))
            oldtext = variableName;
          else if (s.equals(get_gui_id() + "/value"))
            oldtext = value.toString();
          else  return;

          //if the user tried to change but did not press enter
          if (!newtext.replace(" ", "").equals(oldtext)) {
            //resets the test for the original
            Textfield t = (Textfield)cp5.get(s);
            t.setText(oldtext);
          }
        }
      };
  }

  Group load_gui_elements(State s) {
    CallbackListener cb_enter = generate_callback_enter();
		CallbackListener cb_leave = generate_callback_leave();
		this.set_gui_id(s.name + " " + this.get_name());
		String g_name = this.get_gui_id();

    Group g = cp5.addGroup(g_name)
      .setColorBackground(color(255, 50)) //color of the task
      .setBackgroundColor(color(255, 25)) //color of task when openned
      .setBackgroundHeight(90)
      .setLabel(this.get_prefix() + "   " + this.get_name())
      .setHeight(12)
    ;

  g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  int localx = 10, localy = 15, localoffset = 40;
  int w = g.getWidth()-10;

  cp5.addTextfield(g_name+ "/name")
    .setPosition(localx, localy)
    .setSize(w, 15)
    .setGroup(g)
    .setAutoClear(false)
    .setLabel("name")
    .setText(this.variableName)
    .onChange(cb_enter)
    .onReleaseOutside(cb_leave)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
  ;

  cp5.addTextfield(g_name+ "/value")
    .setPosition(localx, localy+localoffset)
    .setSize(w, 15)
    .setGroup(g)
    .setAutoClear(false)
    .setLabel("value")
    .setText(this.value.toString())
    .onChange(cb_enter)
    .onReleaseOutside(cb_leave)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    ;

    return g;
  }

}
