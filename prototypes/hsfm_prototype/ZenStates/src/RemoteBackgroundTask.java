import controlP5.CallbackEvent;
import controlP5.CallbackListener;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.Textfield;
import processing.core.PApplet;

public class RemoteBackgroundTask extends RemoteOSCTask {

	Object red;
	Object green;
	Object blue;

	public RemoteBackgroundTask(PApplet p, ControlP5 cp5, String id) {
		super(p, cp5, id);

		this.message = "/background/";
		this.red = new Expression("0");
		this.green = new Expression("0");
		this.blue = new Expression("0");

		update_content();
	}

	public RemoteBackgroundTask(PApplet p, ControlP5 cp5, String id, String m, Object r, Object g, Object b,
			boolean repeat) {
		super(p, cp5, id);

		this.message = m;
		this.red = r;
		this.green = g;
		this.blue = b;
		this.repeat = repeat;

		update_content();
	}

	Task clone_it() {
		return new RemoteBackgroundTask(this.p, this.cp5, this.name, this.message, this.red, this.green, this.blue,
				this.repeat);
	}

	void update_content() {
		this.content = new Object[] { this.red, this.green, this.blue };

	}

	void update_red(String u) {
		this.red = new Expression(u);
		update_content();
	}

	void update_green(String i) {
		this.green = new Expression(i);
		update_content();
	}

	void update_blue(String r) {
		this.blue = new Expression(r);
		update_content();
	}

	Group load_gui_elements(State s) {

		Group g = super.load_gui_elements(s);
		CallbackListener cb_enter = generate_callback_enter();
		String g_name = this.get_gui_id();
		int w = g.getWidth() - (localx * 2);

		textlabel = "Background Color";
		backgroundheight = (int) ((font_size-1.5) * 16.5);

		g.setBackgroundHeight(backgroundheight);
		g.setLabel(textlabel);

		cp5.addTextfield(g_name + "/red").setPosition(localx, localy).setSize(w, (int) (font_size * 1.25)).setGroup(g)
				.setAutoClear(false).setLabel("red").setText(this.red.toString())
				.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER).onChange(cb_enter)
				.onReleaseOutside(cb_enter).getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);

		cp5.addTextfield(g_name + "/green").setPosition(localx, localy + (1 * localoffset))
				.setSize(w, (int) (font_size * 1.25)).setGroup(g).setAutoClear(false).setLabel("green")
				.setText(this.green.toString())
				.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER).onChange(cb_enter)
				.onReleaseOutside(cb_enter).getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);

		cp5.addTextfield(g_name + "/blue").setPosition(localx, localy + (2 * localoffset))
				.setSize(w, (int) (font_size * 1.25)).setGroup(g).setAutoClear(false).setLabel("blue")
				.setText(this.blue.toString())
				.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER).onChange(cb_enter)
				.onReleaseOutside(cb_enter).getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);

		create_gui_toggle(localx, localy + (3 * localoffset), w, g, cb_enter);
		
		return g;
	}

	@Override
	CallbackListener generate_callback_enter() {
		return new CallbackListener() {
	          public void controlEvent(CallbackEvent theEvent) {

	            //if this group is not open, returns...
	            if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

	            String s = theEvent.getController().getName();

	            if (s.equals(get_gui_id() + "/red")) {
	                String nv = theEvent.getController().getValueLabel().getText();
	                if (nv.trim().equals("")) {
	                  nv="0";
	                  ((Textfield)cp5.get(get_gui_id()+ "/red")).setText(nv);
	                }
	                update_red(nv);
	            }

	            if (s.equals(get_gui_id() + "/green")) {
	                String nv = theEvent.getController().getValueLabel().getText();
	                if (nv.trim().equals("")) {
	                  nv="0";
	                  ((Textfield)cp5.get(get_gui_id()+ "/green")).setText(nv);
	                }
	                update_green(nv);
	            }

	            if (s.equals(get_gui_id() + "/blue")) {
	                String nv = theEvent.getController().getValueLabel().getText();
	                if (nv.trim().equals("")) {
	                  nv="0";
	                  ((Textfield)cp5.get(get_gui_id()+ "/blue")).setText(nv);
	                }
	                update_blue(nv);
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

	    nv = ((Textfield)cp5.get(g_name+"/red")).getText();
	    update_red(nv);
	    nv = ((Textfield)cp5.get(g_name+"/green")).getText();
	    update_green(nv);
	    nv = ((Textfield)cp5.get(g_name+"/blue")).getText();
	    update_blue(nv);

	}

}
