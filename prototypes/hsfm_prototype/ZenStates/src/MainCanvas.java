/************************************************
 ** My canvas class! ****************************
 ************************************************
 ** jeraman.info, Nov. 23 2016 ******************
 ************************************************
 ************************************************/

import controlP5.*;
import netP5.NetAddress;
import oscP5.OscMessage;

import java.util.Vector;

class MainCanvas {

	StateMachine  	   root; 	 //my basic state machine
	Vector<StateMachine> sm_stack; //a stack of sm used for allowing hierarchy

	transient private ZenStates p;
	transient private ControlP5 cp5;
	transient private Button close_preview;

	private boolean is_running;

	//contructor
	public MainCanvas (ZenStates p, ControlP5 cp5) {
		this.p = p;
		this.cp5 = cp5;
		is_running = false;
		
		init_buttons();

		setup();
	}
	
	boolean is_running () {
		return is_running;
	}

	void build(ZenStates p, ControlP5 cp5) {
		System.out.println("@TODO [CANVAS] verify what sorts of things needs to be initialize when loaded from file");
		this.p = p;
		this.cp5 = cp5;
		root.build(p, cp5);
		this.init_buttons();
		//root.show();
	}

	//init my variables
	void setup(){

		//ControlP5 cp5 = HFSMPrototype.instance().cp5();

		root      = new StateMachine(this.p, cp5, "unsaved file");
		sm_stack  = new Vector<StateMachine>();
		sm_stack.add(root);

		root.show();
		
		close_preview.hide();
	}
	
	//initting a new root
	void setup(StateMachine newsm){
		root      = newsm;
		root.build(p, cp5);
		sm_stack  = new Vector<StateMachine>();
		sm_stack.add(newsm);

		root.show();
		close_preview.hide();
	}

	//draw method
	void draw(){

		//executes the hfsm
		root.tick();
		//sm_stack.lastElement().tick();

		//drawing the root
		//root.show();
		//root.draw();
		//sm_stack.lastElement().show();
		sm_stack.lastElement().draw();
		draw_names();
	}

	void draw_names() {
		p.fill(255);
		p.textAlign(p.LEFT);
		String text = root.title.toUpperCase() +" (ROOT)";	
		
		for (int i = 1; i < sm_stack.size(); i++) 
			text += "   >   " + (sm_stack.get(i).title).toUpperCase();
		
		p.text(text, 20, 20);
	}

	//creates a new state and adds its to the root state machine
	void create_state() {
		System.out.println("creates a state");
		State newState = new State(p, cp5, "NEW_STATE_" + ((int)p.random(0, 10)), p.mouseX, p.mouseY);
		//root.add_state(newState);
		this.add_state(newState);
	}
	
	void add_state(State newState) {
		newState.show_gui();
		sm_stack.lastElement().add_state(newState);
		newState.connect_anything_else_to_self();
	}

	//gets the state where the mouse is hoving and removes it form the root state machine
	void remove_state() {
		System.out.println("remove a state");
		//root.remove_state(p.mouseX, p.mouseY);
		sm_stack.lastElement().remove_state(p.mouseX, p.mouseY);
	}
	
	StateMachine get_actual_statemachine () {
		return sm_stack.lastElement();
	}

	//clears the root (not the current exhibited sm)
	void clear() {
		//root.clear();
		sm_stack.lastElement().clear();
	}

	//runs the root (not the current exhibited sm)
	void run() {
		is_running = true;
		root.run();
	}

	//stops the root (not the current exhibited sm)
	void stop() {
		is_running = false;
		stop_server();
		root.stop();
		Blackboard board = ZenStates.instance().board();
		board.reset();
	}
	
	//sends a osc message to stop all media in the server
	void stop_server() {
		OscMessage om = new OscMessage("/stop");
		NetAddress na = new NetAddress(p.SERVER_IP, p.SERVER_PORT);
		p.oscP5().send(om, na);
		p.println("stopping every media in the server");
	}

	void push_root(StateMachine new_sm) {
		//hiding the current state machine
		this.sm_stack.lastElement().hide();
		//pusing the sm to be exhibited as of now
		this.sm_stack.add(new_sm);
		//shows the new state machine
		this.sm_stack.lastElement().show();
		this.close_preview.show();
	}
	
	void show() {
		sm_stack.lastElement().show();
	}
	
	void hide() {
		sm_stack.lastElement().hide();
	}

	void pop_root() {
		//in case there's only the root, nevermind poping
		if (this.sm_stack.size() == 1) return;
		//plays the pop animation
		sm_stack.lastElement().close();
		//otherwise, hides the current state machine
		this.sm_stack.lastElement().hide();
		//pops the last element
		this.sm_stack.remove(this.sm_stack.lastElement());
		//shows the new state machine
		this.sm_stack.lastElement().show();
		//in case this is the root, hides the button again
		if (this.sm_stack.size() == 1) 
			this.close_preview.hide();
	}

	//processes the multiple interpretations of the '+' key
	void process_plus_key_pressed() {

		//reinit any name the user was trying to change it
		//root.reset_all_names_gui();
		sm_stack.lastElement().reset_all_names_gui();

		//verifies if the mouse intersects a state
		//State result = root.intersects_gui(p.mouseX, p.mouseY);
		State result = sm_stack.lastElement().intersects_gui(p.mouseX, p.mouseY);

		//if it does not, creates a new state
		if (result==null)
			create_state();
		//otherwise, opens the pie menu
		else
			//shows the pie
			result.show_pie();

	}

	//processes the multiple interpretations of the '-' key
	void process_minus_key_pressed() {

		//reinit any name the user was trying to change it
		//root.reset_all_names_gui();
		sm_stack.lastElement().reset_all_names_gui();

		//verifies if the mouse intersects a state
		//State result = root.intersects_gui(p.mouseX, p.mouseY);
		State result = sm_stack.lastElement().intersects_gui(p.mouseX, p.mouseY);

		//if it intersects no one, return
		if (result==null) return;

		//first tries to close the pie menu
		if (result.is_pie_menu_open())
			result.hide_pie();
		//otherwise, removes the state
		else
			remove_state();
	}
	

	public void process_copy() {
		p.println("copying!");
		
		//verifies if the mouse intersects a state
		State result = sm_stack.lastElement().intersects_gui(p.mouseX, p.mouseY);
		
		//if it intersects no one, return
		if (result==null) return;
		
		//clonning the intersected state
		State newState = result.clone_it();
		//adding the new tstae to the state machine
		add_state(newState);
		//sets the new state to drag
		newState.start_gui_dragging();
		
	}

	//processes ui in case the shfit key was pressed
	void process_shift_key() {
		//verifies if the mouse intersects a state
		//State result = root.intersects_gui(p.mouseX, p.mouseY);
		State result = sm_stack.lastElement().intersects_gui(p.mouseX, p.mouseY);

		//if it does not, creates a new state
		if (result!=null) {
			System.out.println("mouse was pressed while holding shift key in state " + result.get_name());
			result.freeze_movement_and_trigger_connection();
		}
	}


	void init_buttons() {
		int w = 40;
		int h = 40;
		int offset = 5;
		//int x = 20; //p.width/2;
		int x = (p.width/2)-2*(w+offset);
		int y = p.height-80;


		int back = p.color(255, 255, 255, 50);
		int font = p.color(50);

		CallbackListener cb_click = generate_callback_click();

		cp5.addButton("button_play")
		.setValue(128)
		.setPosition(x, y)
		.setColorBackground(back)
		.setWidth(w)
		.setHeight(h)
		.onPress(cb_click)
		.setLabel("play")
		;


		cp5.addButton("button_stop")
		.setValue(128)
		.setPosition(x+w+offset, y)
		.setColorBackground(back)
		.setWidth(w)
		.setHeight(h)
		.onPress(cb_click)
		.setLabel("stop")
		;

		//don't know why, but using b_save, button_saving generate problems in cp5
		cp5.addButton("button_save")
		.setValue(128)
		.setPosition(x+(2*w)+(2*offset), y)
		.setColorBackground(back)
		.setWidth(w)
		.setHeight(h)
		.onPress(cb_click)
		.setLabel("save")
		;

		cp5.addButton("button_load")
		.setValue(128)
		.setPosition(x+(3*w)+(3*offset), y)
		.setColorBackground(back)
		.setWidth(w)
		.setHeight(h)
		.onPress(cb_click)
		.setLabel("load")
		;
		
		close_preview = new Button(cp5, "close_preview");
		close_preview.setValue(128);
		close_preview.setPosition(20, 40);
		close_preview.setLabel("close preview");
		close_preview.hide();
		close_preview.onPress(generate_callback_close());
	}


	//callback functions
	void button_play() {
		if (p.is_loading) return;
		p.println("b_play pressed");
		run();
		//p.canvas.run();
	}

	void button_stop() {
		if (p.is_loading) return;
		p.println("b_stop pressed");
		stop();
		//p.canvas.stop();
	}
	
	void button_save() {
		if (p.is_loading) return;
		p.println("b_save pressed");
		stop();
		save();
	}
	
	void save() {
		p.serializer.save();
		root.save();
	}

	void button_load() {
		if (p.is_loading) return;
		p.println("b_load pressed");
		load();
	}
	
	void load() {
		stop();
		p.serializer.load();
	}

	
	CallbackListener generate_callback_close() {
		return new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {
				//close the current open state machine
				pop_root();
				p.println("should close it!!!!");
			}
		};
	}

	CallbackListener generate_callback_click() {
		return new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {

				String s = theEvent.getController().getName();

				if (s.equals("button_play")) button_play();
				if (s.equals("button_stop")) button_stop();
				if (s.equals("button_save")) button_save();
				if (s.equals("button_load")) button_load();
			}
		};
	}

}
