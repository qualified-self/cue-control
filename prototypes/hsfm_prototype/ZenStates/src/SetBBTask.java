/************************************************
************************************************
** implementing a task for setting the blackboard
************************************************
************************************************/

import controlP5.*;
import processing.core.PApplet;


class SetBBTask extends Task {

  Object value;
  String variableName;

  public SetBBTask (PApplet p, ControlP5 cp5, String taskname, Object value) {
    super(p, cp5, taskname);
    this.variableName = taskname;
    this.value = value;
  }

  /*
  public SetBBTask (PApplet p, String taskname, Object value) {
    super(p, taskname);
    this.value = value;
  }
  */

  void build(PApplet p, ControlP5 cp5) {
    this.p = p;
    this.cp5 = cp5;
  }

  SetBBTask clone_it() {
    return new SetBBTask(this.p, this.cp5, this.name, this.value);
  }

  void run() {
    if (!should_run()) return;

    Blackboard board = ZenStates.instance().board();
    this.status = Status.RUNNING;
    board.put(variableName, evaluate_value(value));
    this.status = Status.DONE;
  }

  void stop() {
    super.stop();
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



  Group load_gui_elements(State s) {
    //PApplet p = HFSMPrototype.instance();
    CallbackListener cb_enter = generate_callback_enter();
		CallbackListener cb_leave = generate_callback_leave();
    //ControlP5 cp5 = HFSMPrototype.instance().cp5();
    int c1 = p.color(255, 50);
    int c2 = p.color(255, 25);

		//this.set_gui_id(s.get_name() + " " + this.get_name());
		String g_name = this.get_gui_id();

    Group g = cp5.addGroup(g_name)
      .setColorBackground(c1) //color of the task
      .setBackgroundColor(c2) //color of task when openned
      .setBackgroundHeight(150)
      .setLabel("Blackboard variable")
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
    .onReleaseOutside(cb_enter)
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
    .onReleaseOutside(cb_enter)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    ;

    create_gui_toggle(localx, localy+(2*localoffset), w, g, cb_enter);

    return g;
  }

  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {

          //if this group is not open, returns...
          if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

          String s = theEvent.getController().getName();
          //println(s + " was entered");

          if (s.equals(get_gui_id() + "/name")) {
              String text = theEvent.getController().getValueLabel().getText();
              //if the name is empty, resets
              if (text.trim().equalsIgnoreCase("")) {
                ((Textfield)cp5.get(get_gui_id() + "/name")).setText(name);
                return;
              }
              update_variable_name(text);
              System.out.println(s + " " + text);
          }
          if (s.equals(get_gui_id() + "/value")) {
              String newvalue = theEvent.getController().getValueLabel().getText();
              //if the name is empty, resets
              if (newvalue.trim().equalsIgnoreCase("")) {
                ((Textfield)cp5.get(get_gui_id() + "/value")).setText(value.toString());
                return;
              }
              update_value(new Expression(newvalue));
              System.out.println(s + " " + newvalue);
          }

          check_repeat_toggle(s, theEvent);
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
            //ControlP5 cp5 = HFSMPrototype.instance().cp5();
            Textfield t = (Textfield)cp5.get(s);
            t.setText(oldtext);
          }
        }
      };
  }

  void reset_gui_fields() {
    String g_name = this.get_gui_id();
    String nv;

    //if this group is not open, returns...
    if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

    nv = ((Textfield)cp5.get(g_name+"/name")).getText();
    update_variable_name(nv);
    nv = ((Textfield)cp5.get(g_name+"/value")).getText();
    update_value(nv);

  }

}
