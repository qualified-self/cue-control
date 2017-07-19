import controlP5.CallbackEvent;
import controlP5.CallbackListener;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.Textfield;
import processing.core.PApplet;

public class RemoteSinewaveTask extends RemoteOSCTask {

	Object frequency;
	Object amplitude;
	
	public RemoteSinewaveTask(PApplet p, ControlP5 cp5, String id) {
		super(p, cp5, id);

		this.message = "/sinewave/";
		this.frequency = new Expression("0");
		this.amplitude = new Expression("0");

		update_content();
	}

	public RemoteSinewaveTask(PApplet p, ControlP5 cp5, String id, String m, Object f, Object a, boolean repeat) {
		super(p, cp5, id);

		this.message = m;
		this.frequency = f;
		this.amplitude = a;
		this.repeat = repeat;

		update_content();
	}
	
	Task clone_it() {
		return new RemoteSinewaveTask(this.p, this.cp5, this.name, this.message, this.frequency, this.amplitude, this.repeat);
	}

	void update_content() {
		this.content = new Object[] { this.frequency, this.amplitude};

	}
	
	void update_frequency(String u) {
		this.frequency = new Expression(u);
		update_content();
	}

	void update_amplitude(String i) {
		this.amplitude = new Expression(i);
		update_content();
	}
	
	Group load_gui_elements(State s) {

		Group g = super.load_gui_elements(s);
		CallbackListener cb_enter = generate_callback_enter();
		String g_name = this.get_gui_id();
		int w = g.getWidth() - (localx * 2);

		textlabel = "Sinewave";
		backgroundheight = (int) ((font_size-1.5) * 16.5);

		g.setBackgroundHeight(backgroundheight);
		g.setLabel(textlabel);

		cp5.addTextfield(g_name + "/frequency").setPosition(localx, localy).setSize(w, (int) (font_size * 1.25)).setGroup(g)
				.setAutoClear(false).setLabel("frequency").setText(this.frequency.toString())
				.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER).onChange(cb_enter)
				.onReleaseOutside(cb_enter).getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);

		cp5.addTextfield(g_name + "/amplitude").setPosition(localx, localy + (1 * localoffset))
				.setSize(w, (int) (font_size * 1.25)).setGroup(g).setAutoClear(false).setLabel("amplitude")
				.setText(this.amplitude.toString())
				.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER).onChange(cb_enter)
				.onReleaseOutside(cb_enter).getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);

		create_gui_toggle(localx, localy + (2 * localoffset), w, g, cb_enter);
		
		return g;
	}
	

	@Override
	CallbackListener generate_callback_enter() {
		return new CallbackListener() {
	          public void controlEvent(CallbackEvent theEvent) {

	            //if this group is not open, returns...
	            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

	            String s = theEvent.getController().getName();

	            if (s.equals(get_gui_id() + "/frequency")) {
	            	String nv = theEvent.getController().getValueLabel().getText();
	            	if (nv.trim().equals("")) {
	            		nv="0";
	            		((Textfield)cp5.get(get_gui_id()+ "/frequency")).setText(nv);
	            	}
	            	update_frequency(nv);
	            }
	            
	            if (s.equals(get_gui_id() + "/amplitude")) {
	                String nv = theEvent.getController().getValueLabel().getText();
	                if (nv.trim().equals("")) {
	                  nv="0";
	                  ((Textfield)cp5.get(get_gui_id()+ "/amplitude")).setText(nv);
	                }
	                update_amplitude(nv);
	            }


	            check_repeat_toggle(s, theEvent);
	          }
	    };
	}

	@Override
	void reset_gui_fields() {
	    String g_name = this.get_gui_id();
	    String nv;

	    //if this group is not open, returns...
	    if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

	    nv = ((Textfield)cp5.get(g_name+"/frequency")).getText();
	    update_frequency(nv);
	    nv = ((Textfield)cp5.get(g_name+"/amplitude")).getText();
	    update_amplitude(nv);

	}

}
