


import controlP5.*;
import processing.core.PApplet;


////////////////////////////////////////
//implementing a task for OSC messages
public class ControlRemoteDMXTask extends RemoteOSCTask {

  Object channel;
  Object intensity;
  Object rate;
  Object duration;

  //contructor loading the file
  public ControlRemoteDMXTask (PApplet p, ControlP5 cp5, String id) {
    super(p, cp5, id);

    this.message   = "/dmx/control";
    this.channel  = new Expression("1");
    this.intensity = new Expression("0");
    this.duration  = new Expression("0");
    this.rate      = new Expression("0");

    update_content();
  }

  //contructor loading the file
  public ControlRemoteDMXTask (PApplet p, ControlP5 cp5, String id, String m, Object c, Object i, Object d, Object r, boolean repeat) {
	  super(p, cp5, id);
	  
	  this.message   = m;
	  this.channel   = c;
	  this.intensity = i;
	  this.duration  = d;
	  this.rate      = r;
	  this.repeat	 = repeat;
	  
	  update_content();
  }

  ControlRemoteDMXTask clone_it () {
    return new ControlRemoteDMXTask(this.p, this.cp5, this.name, this.message, this.channel, this.intensity, this.duration, this.rate, this.repeat);
  }

  void update_content () {
    this.content  = new Object[] {this.channel, this.intensity, this.rate, this.duration};
  }

  void update_channel (String u) {
    this.channel = new Expression(u);
    update_content();
  }

  void update_intensity (String i) {
    this.intensity = new Expression(i);
    update_content();
  }

  void update_rate (String r) {
    this.rate = new Expression(r);
    update_content();
  }

  void update_duration(String d) {
    this.duration = new Expression(d);
    update_content();
  }


  //UI config
  Group load_gui_elements(State s) {

    CallbackListener cb_enter = generate_callback_enter();
    //CallbackListener cb_leave = generate_callback_leave();

    //this.set_gui_id(s.get_name() + " " + this.get_name());
    String g_name = this.get_gui_id();
    
    String textlabel = "Control DMX";
    int font_size 	 = (int)(((ZenStates)p).get_font_size());
    int textwidth 	 = (int)((ZenStates)p).textWidth(textlabel);
    int backgroundheight = (int)(font_size* 16.5);

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

    cp5.addTextfield(g_name+ "/channel")
      .setPosition(localx, localy)
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("channel")
      .setText(this.channel.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    cp5.addTextfield(g_name+ "/intensity")
      .setPosition(localx, localy+(1*localoffset))
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("intensity")
      .setText(this.intensity.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    cp5.addTextfield(g_name+ "/rate")
      .setPosition(localx, localy+(2*localoffset))
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("rate")
      .setText(this.rate.toString())
      .align(ControlP5.CENTER, ControlP5.CENTER,ControlP5.CENTER, ControlP5.CENTER)
      .onChange(cb_enter)
      .onReleaseOutside(cb_enter)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
    ;

    cp5.addTextfield(g_name+ "/duration")
      .setPosition(localx, localy+(3*localoffset))
      .setSize(w, (int)(font_size*1.25))
      .setGroup(g)
      .setAutoClear(false)
      .setLabel("duration")
      .setText(this.duration.toString())
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

            if (s.equals(get_gui_id() + "/channel")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="0";
                  ((Textfield)cp5.get(get_gui_id()+ "/channel")).setText(nv);
                }
                update_channel(nv);
            }

            if (s.equals(get_gui_id() + "/intensity")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="0";
                  ((Textfield)cp5.get(get_gui_id()+ "/intensity")).setText(nv);
                }
                update_intensity(nv);
            }

            if (s.equals(get_gui_id() + "/rate")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="0";
                  ((Textfield)cp5.get(get_gui_id()+ "/rate")).setText(nv);
                }
                update_rate(nv);
            }

            if (s.equals(get_gui_id() + "/duration")) {
                String nv = theEvent.getController().getValueLabel().getText();
                if (nv.trim().equals("")) {
                  nv="0";
                  ((Textfield)cp5.get(get_gui_id()+ "/duration")).setText(nv);
                }
                update_duration(nv);
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

    nv = ((Textfield)cp5.get(g_name+"/channel")).getText();
    update_channel(nv);
    nv = ((Textfield)cp5.get(g_name+"/intensity")).getText();
    update_intensity(nv);
    nv = ((Textfield)cp5.get(g_name+"/rate")).getText();
    update_rate(nv);
    nv = ((Textfield)cp5.get(g_name+"/duration")).getText();
    update_duration(nv);
  }


}
