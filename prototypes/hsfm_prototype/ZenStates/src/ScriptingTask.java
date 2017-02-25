import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.script.ScriptContext;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

import controlP5.CallbackEvent;
import controlP5.CallbackListener;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.Textfield;
import processing.core.PApplet;

public class ScriptingTask extends Task {

	private static final long serialVersionUID = 1L;
	transient static ScriptEngine  engine;
	transient static ScriptContext context;
	transient 		 FileReader    script;

	public ScriptingTask(PApplet p, ControlP5 cp5, String taskname) {
		super(p, cp5, taskname);
		load_scripts ();
		set_context();
	}

	@Override
	void run() {
		if (!should_run()) return;

		this.status = Status.RUNNING;

		// TODO Auto-generated method stub
		try {
			load_scripts();
			update_context();
			p.println("evaluating script " + name);
			engine.eval(script, context);
			
		} catch (ScriptException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		this.status = Status.DONE;
	}

	@Override
	void build(PApplet p, ControlP5 cp5) {
		this.p = p;
		this.cp5 = cp5;
		load_scripts();
		set_context();
	}

	//loading the required engines
	void load_scripts () {
		//if it's loading the engine for the first time
		if (engine==null)
			engine = new ScriptEngineManager().getEngineByName("nashorn");

		try {
			script = new FileReader(p.sketchPath()+"/data/"+name);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	void set_context () {
		context = engine.getContext();
		// stores an object under the key `myKey` in the (engine scoped) context
		//context.setAttribute("board", ((ZenStates)p).board, ScriptContext.ENGINE_SCOPE);
	}
	
	void update_context() {
		Blackboard b = ((ZenStates)p).board();
		List<String> ordered = new ArrayList<String>(b.keySet());

		for(String val : ordered) {
			//drawItem(val, this.get(val), x, y+(myheight*(i+1))+i+1, mywidth, myheight);
			context.setAttribute(val, b.get(val), ScriptContext.ENGINE_SCOPE);
		}
		context.setAttribute("blackboard", b, ScriptContext.ENGINE_SCOPE);
		
	}

	@Override
	void update_status() {
	}

	@Override
	Task clone_it() {
		return new ScriptingTask(p, cp5, name);
	}
	
	void update_name(String newname) {		
		this.name = newname;
	}


	@Override
	CallbackListener generate_callback_enter() {
		return new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {

				//if this group is not open, returns...
				if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

				String s = theEvent.getController().getName();
				//println(s + " was entered");

				if (s.equals(get_gui_id() + "/filename")) {
					String text = theEvent.getController().getValueLabel().getText();
					//if the name is empty, resets
					if (text.trim().equalsIgnoreCase("")) {
						((Textfield)cp5.get(get_gui_id() + "/filename")).setText(name);
						return;
					}
					update_name(text);
					System.out.println(s + " " + text);
				}
				
				check_repeat_toggle(s, theEvent);
			}
		};
	}

	@Override
	Group load_gui_elements(State s) {
		// TODO Auto-generated method stub
		CallbackListener cb_enter = generate_callback_enter();
		
		int c1 = p.color(255, 50);
		int c2 = p.color(255, 25);

		String g_name = this.get_gui_id();

		Group g = cp5.addGroup(g_name)
				.setColorBackground(c1) //color of the task
				.setBackgroundColor(c2) //color of task when openned
				.setBackgroundHeight(150)
				.setLabel("Scripting")
				.setHeight(12)
				;

		g.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

		int localx = 10, localy = 15, localoffset = 40;
		int w = g.getWidth()-10;

		cp5.addTextfield(g_name+ "/filename")
		.setPosition(localx, localy)
		.setSize(w, 15)
		.setGroup(g)
		.setAutoClear(false)
		.setLabel("filename")
		.setText(this.name)
		.onChange(cb_enter)
		.onReleaseOutside(cb_enter)
		.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
		;
		
		create_gui_toggle(localx, localy+(2*localoffset), w, g, cb_enter);
		
		return g;
	}

	@Override
	void reset_gui_fields() {
		String g_name = this.get_gui_id();
		String nv;

		//if this group is not open, returns...
		if (!((Group)cp5.get(get_gui_id())).isOpen()) return;

		nv = ((Textfield)cp5.get(g_name+"/filename")).getText();
		update_name(nv);
	}

}
