

import controlP5.*;
import processing.core.PApplet;


class SetBBOscillatorTask extends SetBBTask {
  private Object frequency;
  private Object amplitude;

  public SetBBOscillatorTask (PApplet p, ControlP5 cp5) {
    super(p, cp5, ("osc_" + (int)p.random(0, 100)), new Expression("1"));

    update_frequency("1");
    update_amplitude("1");
    //update_content();
  }
  
  //clone function
  SetBBOscillatorTask clone_it() {
	  SetBBOscillatorTask clone = new SetBBOscillatorTask(this.p, this.cp5);
	  
	  clone.variableName	= this.variableName;
	  clone.frequency 		= this.frequency;
	  clone.amplitude 		= this.amplitude;
	  clone.value 			= this.value;
	  clone.timerMilestone 	= this.timerMilestone;
	  clone.timer          	= this.timer;
	  clone.repeat			= this.repeat;
	  
	  return clone;
  }

  void update_frequency(String v) {
    this.frequency = new Expression(v);
    //update_content();
  }

  void update_amplitude(String v) {
    this.amplitude = new Expression(v);
    //update_content();
  }

  void run() {
	
    if (!should_run()) return;

    String freq_val = (evaluate_value(this.frequency)).toString();
    String amp_val  = (evaluate_value(this.amplitude)).toString();
    
    //String rootTimer = "$" + ((ZenStates)p).canvas.root.get_formated_blackboard_title() + "_timer";

    //Expression ne = new Expression(amp_val+"*math.sin("+rootTimer+"*"+freq_val+")");
    Expression ne = new Expression(amp_val+"*math.sin("+timer+"*"+freq_val+")");

    Blackboard board = ZenStates.instance().board();
    this.status = Status.RUNNING;
    board.put(variableName, evaluate_value(ne));
    this.status = Status.DONE;
  }

  //UI config
  Group load_gui_elements(State s) {

    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();
    
    String textlabel = "Oscillator variable";
    int font_size 	 = (int)(((ZenStates)p).get_font_size());
    int textwidth 	 = (int)((ZenStates)p).textWidth(textlabel);
    int backgroundheight = (int)(font_size* 13.5);

    //ControlP5 cp5 = HFSMPrototype.instance().cp5();

    Group g = cp5.addGroup(g_name)
    	    //.setPosition(x, y) //change that?
    	    .setHeight(font_size)
    	    .setWidth((10*((ZenStates)p).FONT_SIZE))
    	    .setBackgroundHeight(backgroundheight)
    	    .setColorBackground(p.color(255, 50)) //color of the task
    	    .setBackgroundColor(p.color(255, 25)) //color of task when openned
    	    .setLabel(textlabel)
    	    ;


    g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    int localx = 10, localy = (int)(font_size), localoffset = 3*font_size;
    int w = g.getWidth()-(localx*2);


    cp5.addTextfield(g_name+ "/name")
      .setPosition(localx, localy)
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("name")
      .setText(this.variableName)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
    ;

    cp5.addTextfield(g_name+ "/frequency")
      .setPosition(localx, localy+(1*localoffset))
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("frequency")
      .setText(this.frequency.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    cp5.addTextfield(g_name+ "/amplitude")
      .setPosition(localx, localy+(2*localoffset))
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("amplitude")
      .setText(this.amplitude.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    create_gui_toggle(localx, localy+(3*localoffset), w, g, cb_enter);

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
                //System.out.println(s + " " + text);
            }

            if (s.equals(get_gui_id() + "/frequency")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="1";
                  ((Textfield)cp5.get(get_gui_id()+ "/frequency")).setText(nv);
                }
                update_frequency(nv);
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
	  nv = ((Textfield)cp5.get(g_name+"/frequency")).getText();
	  update_frequency(nv);
	  nv = ((Textfield)cp5.get(g_name+"/amplitude")).getText();
	  update_amplitude(nv);

  }
}
