

import controlP5.*;
import processing.core.PApplet;


class SetBBRampTask extends SetBBTask {
  protected Object duration;
  protected Object amplitude;
  protected boolean is_up;

  public SetBBRampTask (PApplet p, ControlP5 cp5) {
    super(p, cp5, ("ramp_" + (int)p.random(0, 100)), new Expression("1"));

    this.is_up = true;

    update_duration("1");
    update_amplitude("1");
  }

  void update_duration(String v) {
    this.duration = new Expression(v);
  }

  void update_amplitude(String v) {
    this.amplitude = new Expression(v);
  }
  
  private String start_timer = null;

  void run() {
    if (!should_run()) return;
    
    if (variableName.equals("ramp2")) {
    	int testing = 0;
    	testing +=1;
    }

    String dur_val = evaluate_value(this.duration).toString();
    String amp_val = evaluate_value(this.amplitude).toString();

    Expression ne;
    
    String rootTimer = "$" + ((ZenStates)p).canvas.root.get_formated_blackboard_title() + "_timer";
    
    //if this is the first time, need to save when execution started
    if (first_time) {
    	ne = new Expression(rootTimer);
    	start_timer = evaluate_value(ne).toString();
    }
    	
    //if (is_up) ne = new Expression(amp_val+"*(("+rootTimer+"/"+dur_val+") % 1)");
    //else       ne = new Expression("math.abs("+amp_val+"-("+amp_val+"*(("+rootTimer+"/"+dur_val+") % 1)))");
    if (is_up) ne = new Expression(amp_val+"*((("+rootTimer+"-"+start_timer+")/"+dur_val+") % 1)");
    else       ne = new Expression("math.abs("+amp_val+"-("+amp_val+"*((("+rootTimer+"-"+start_timer+")/"+dur_val+") % 1)))");

    Blackboard board = ZenStates.instance().board();
    this.status = Status.RUNNING;
    
    Object result = evaluate_value(ne);
    
    board.put(variableName, result);
    //this.status = Status.DONE;
  }
  
  void stop() {
	  super.stop();
	  start_timer = null;
  }

  //UI config
  Group load_gui_elements(State s) {

    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();

    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    Group g = cp5.addGroup(g_name)
    //.setPosition(x, y) //change that?
    .setHeight(12)
    .setBackgroundHeight(220)
    .setColorBackground(p.color(255, 50)) //color of the task
    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    .setLabel("Ramp variable")
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

    // create a toggle
    cp5.addToggle(get_gui_id()+"/type")
       .setPosition(localx, localy+(1*localoffset))
       .setSize(w, 15)
       .setGroup(g)
       .setMode(ControlP5.SWITCH)
       .setLabel("up              down")
       .setValue(this.is_up)
       .onChange(cb_enter)
       .onReleaseOutside(cb_enter)
       .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
       ;

    cp5.addTextfield(g_name+ "/duration")
      .setPosition(localx, localy+(2*localoffset))
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("duration")
      .setText(this.duration.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    cp5.addTextfield(g_name+ "/amplitude")
      .setPosition(localx, localy+(3*localoffset))
      .setSize(w, 15)
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("amplitude")
      .setText(this.amplitude.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    create_gui_toggle(localx, localy+(4*localoffset), w, g, cb_enter);

    return g;
  }

  CallbackListener generate_callback_enter() {
    return new CallbackListener() {
          public void controlEvent(CallbackEvent theEvent) {

            //if this group is not open, returns...
            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

            String s = theEvent.getController().getName();

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

            if (s.equals(get_gui_id() + "/type")) {
                float value = theEvent.getController().getValue();
                if (value==0.0)  is_up = false; //once
                else             is_up = true;  //repeat
            }

            if (s.equals(get_gui_id() + "/duration")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="1";
                  ((Textfield)cp5.get(get_gui_id()+ "/duration")).setText(nv);
                }
                update_duration(nv);
            }

            if (s.equals(get_gui_id() + "/amplitude")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="1";
                  ((Textfield)cp5.get(get_gui_id()+ "/amplitude")).setText(nv);
                }
                update_amplitude(nv);
            }

            check_repeat_toggle(s, theEvent);
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
	  nv = ((Textfield)cp5.get(g_name+"/duration")).getText();
	  update_duration(nv);
	  nv = ((Textfield)cp5.get(g_name+"/amplitude")).getText();
	  update_amplitude(nv);

  }

}
