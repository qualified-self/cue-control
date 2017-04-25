/************************************************
 ** Class representing a state in the HFSM
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

////////////////////////////////////////
//importing whatever we need
import java.util.*;
import java.io.Serializable;
import processing.core.PApplet;
import controlP5.*;
import java.util.UUID;

////////////////////////////////////////
//the state class
public class State implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Vector<Connection> connections;
	private Vector<Task>       tasks;
	private String             name;
	private Status             status;
	private MovementStatus     movement_status;
	public boolean             is_actual;
	public boolean             debug;
	static boolean is_dragging_someone = false;

	//variables used for the gui
	public int          x;
	public int          y;
	private final int   size = 50;
	private final float arrow_scale_offset = 1.25f;
	private String      id;
	//accordion that stores the tasks

	//gui elements
	//transient private PieMenu   pie;
	transient private MultiLevelPieMenu   pie;
	transient private Accordion accordion;
	transient private Textfield label;
	transient private PApplet   p;
	transient private ControlP5 cp5;

	//constructor
	public State(PApplet p, ControlP5 cp5, String name) {
		this.p = p;
		this.cp5 = cp5;
		this.name   = name.toUpperCase();
		this.status = Status.INACTIVE;
		this.tasks  = new Vector<Task>();
		this.connections = new Vector<Connection>();
		this.x = (int)p.random(10, p.width-size);
		this.y = (int)p.random(10, p.height-size);
		this.movement_status = MovementStatus.FREE;
		this.debug = ZenStates.instance().debug();
		this.id    = UUID.randomUUID().toString();
		
		init_gui();
		hide_gui();
		
		this.connect_anything_else_to_self();

		this.is_actual = false;
		
	}

	//constructor
	public State(PApplet p, ControlP5 cp5, String name, int x, int y) {
		this(p, cp5, name);
		this.x = x;
		this.y = y;
		pie.set_position(x,y);
		//animation.set_position(x, y);
	}

	//@TODO IMMPLEMENT BUILD THAT LOADS THE UI ELEMENTS OF THE STATE
	void build (PApplet p, ControlP5 cp5) {
		this.p = p;
		this.cp5 = cp5;
		//this.id    = UUID.randomUUID().toString();
		
		//builds the tasks
		for (Connection c : connections)
			c.build(p, cp5);

		//builds the tasks
		for (Task t : tasks) {
			t.build(p, cp5);
		}
		
		//loads the gui
		init_gui();
		hide_gui();

		//add all tasks to gui
		this.add_all_tasks_to_gui();
	}

	String get_name() {
		return this.name;
	}

	String get_id() {
		return this.id;
	}
	
	void set_id(String newid) {
		this.id = id;
	}
	
	
	void reinit_id () {
		//updates the id
		this.id = UUID.randomUUID().toString();
		reset_group_id_gui_of_all_tasks();
	}
	
	
	
	State clone_it () {
		//cloning the simple attributes of this state
		State clone = new State(p, cp5, name);
		
		//cloning all tasks
		for (Task t : tasks) 
			clone.add_task(t.clone_it());
		
		//cloning all connections from this state
		//for (Connection c : connections) 
		//	clone.a
		
		//cloning all connections to this state	
			
		return clone;
	}
	
	void check_if_any_substatemachine_needs_to_be_reloaded_from_file () {
		for (Task t : tasks) 
			if (t instanceof StateMachine)
				((StateMachine)t).reload_from_file();
	}

	//run all tasks associated to this node
	void run () {
		for (Task t : tasks) 
			t.run();

		this.status = Status.RUNNING;

		if(debug)
			System.out.println("running all the " + tasks.size() +" tasks from state " + this.name);
	}

	//stops all tasks associated to this node
	void stop() {
		for (Task t : tasks)
			t.stop();

		this.status = Status.INACTIVE;

		if(debug)
			System.out.println("stopping all tasks from state " + this.name);
	}

	void clear() {
		this.remove_all_tasks();
		this.remove_all_tasks_from_gui();
		this.remove_all_connections();
		//ControlP5 cp5 = HFSMPrototype.instance().cp5();
		//removes the old gui label
		//cp5.remove(this.name);
		cp5.remove(this.id+"/label");
		//cp5.remove("/acc_"+this.name);
		cp5.remove(this.id+"/acc");
		//removes all tasks from the gui
	}

	//stops all tasks associated to this node
	void interrupt() {
		for (Task t : tasks)
			t.interrupt();

		this.status = Status.DONE;

		if(debug)
			System.out.println("interrupting all tasks from state " + this.name);
	}

	//if it's entering a state, you need to refresh it
	void refresh() {
		for (Task t : tasks)
			t.refresh();
	}
	
	//in case there are statemachine inside this state, this machine should be saved to file
	void save() {
		for (Task t : tasks)
			if (t instanceof StateMachine)
				((StateMachine)t).save();
	}

	//if it's entering a state, you need to refresh it
	void reset_first_time() {
		for (Task t : tasks)
			t.reset_first_time();
	}

	//only refreshes and reruns completed tasks
	void refresh_and_run_completed_tasks() {
		for (Task t : tasks)
			if (t.get_status () == Status.DONE || t.get_status () == Status.INACTIVE) {
				t.refresh();
				t.run();
			}
	}

	//gets the current status of this state
	Status get_status() {
		return this.status;
	}

	//updates the status of this state
	void update_status () {

		//if there are no tasks, the state is done
		if (tasks.size()==0)
			this.status = Status.DONE;

		//updates the status first
		for (Task t : tasks)
			t.update_status();

		//gets the status of the tasks associated to this state and updates accordingly
		for (Task t : tasks) {
			Status temporary_status = t.get_status();
			//updates accordingly
			if (temporary_status == Status.INACTIVE) {
				this.status = Status.INACTIVE;
				break;
			}

			if (temporary_status == Status.RUNNING) {
				this.status = Status.RUNNING;
				//if this is a State_Machine
				//if (t instanceof State_Machine)

				break;
			}

			if (temporary_status == Status.DONE)
				this.status = Status.DONE;
		}

		//println("State " + this.name + "state was updated to " + this.status);
	}


	//function called everytime there is a new input
	State tick() {
		State my_return = this;

		//ticks all subState_Machine that are inside this state
		if (this.status==Status.RUNNING)
			for (Task t : tasks) if (t instanceof StateMachine) ((StateMachine)t).tick();

		//if (this.status==Status.DONE)
		my_return = this.change_state();

		//else //not ready yet...
		//println("State " + this.name + " is not ready to change!");

		return my_return;
	}

	//tries to change the current state. returns the next state if it's time to change
	State change_state() {

		//if it' not done yet, not ready to change
		//if (this.status!=Status.DONE) {
		//println("State " + this.name + " is not ready to change!");
		//  return null;
		//}

		//if done, looks for the next state
		State next_state = null;

		//iterates over array
		for (Connection c : connections) {
			//looks if c's condition corresponds to the current input. if so changes the state
			if (c.is_condition_satisfied()) {
				next_state = c.get_next_state();

				//if it's going to another state
				if (next_state != this) {
					//interrupts current activities that are still going on
					this.interrupt();
					//refresh the next state
					next_state.refresh();
					//reset_first_time
					next_state.reset_first_time();
					//runs the next state
					next_state.run();

					//if (next_state.get_name().equals("END_ROOT"))
					//  System.out.println("State was " + this.name + " . Now it is changing to " + next_state.name);

					break;
				}

				//if this is a transition to this very same state
				else {
					if (debug)
						System.out.println("this is a transition to self!!! state: " + this.name);
					//refreshes currently stopped tasks
					this.refresh_and_run_completed_tasks();
					break;
				}
			}
		}

		if (next_state==null)
			if (debug)
				System.out.println("State " + this.name + " doesn't have a connection for this input! this can be a bug!");

		return next_state;
	}


	//add a task t to this state
	void add_task(Task t) {
		tasks.addElement(t);
		if (debug)
			System.out.println("Task " + t.name + " added to state " + this.name);

		//updates the gui
		add_task_in_accordion_gui(t);
	}

	//remove a task t from this state
	void remove_task(Task t) {
		if (tasks.contains(t)) {
			//removes the physical task
			this.tasks.removeElement(t);
			//removes the task in gui
			this.remove_task_in_accordion_gui(t);
		} else
			if (debug)
				System.out.println("Unable to remove task " + t.name + " from state " + this.name);

		//updates the gui
		//remove_task_in_accordion_gui(t);
	}

	//removes all tasks associated to this state
	void remove_all_tasks() {
		//iterating over the array backwards
		for (int i = tasks.size()-1; i >=0 ; i--) {
			this.remove_task(tasks.get(i));
		}
	}

	void remove_all_connections_to_a_state (State dest) {
		//iterating over connections backwards
		for (int i = connections.size()-1; i >=0 ; i--) {
			Connection c = connections.get(i);
			if (c.get_next_state()==dest)
				this.disconnect(c);
		}

		this.reload_connections_gui();
	}
	
	void update_all_connections_to_a_state (State dest, String newid) {
		//iterating over connections backwards
		for (int i = connections.size()-1; i >=0 ; i--) {
			Connection c = connections.get(i);
			if (c.get_next_state()==dest) 
				c.update_id_next_state(newid);
				//all connections are automatically realoaded inside the last method. no need to do it again.
		}
	}
	
	void update_all_connections_from_this_state () {
		//iterating over connections backwards
		for (int i = connections.size()-1; i >=0 ; i--) {
			Connection c = connections.get(i);
			c.update_parent(this.get_id());
			//all connections are automatically realoaded inside the last method. no need to do it again.
		}
	}

	void reload_connections_gui() {
		for (Connection c : connections)
			c.reload_gui_items();
	}

	//add a connection to this state
	void connect(Expression expression, State next_state) {
		//if there is already a connection next_state, do nothing
		if (there_is_already_a_connection_to_state(next_state)) return;

		int p = connections.size()+1;

		//in case the condition hasnt been used, create a new connection
		Connection c = new Connection(this.p, this.cp5, this, next_state, expression, p);

		//@TODO add item from all dropdown lists
		connections.addElement(c);
		//reload_connections_gui();

		//if there is already a transition to self, and it's not the one we just created
		if (there_is_already_a_connection_to_state(this) && next_state!=this)
			//update its priority to the last
			update_priority(p-1, p);


		if (debug)
			System.out.println("Connection created. If " + this.name + " receives " + expression.toString() + ", it goes to state " + next_state.name);
	}

	void update_all_priorities () {
		for (int i = 0; i < connections.size(); i++) {
			Connection c = connections.get(i);
			c.update_priority(i+1);
		}
	}

	void update_priority(int oldPriority, int newPriority) {
		//change the position of the connection in the Vector
		//udpate all connections
		//reload gui elements

		Connection item = connections.get(oldPriority-1);
		connections.remove(oldPriority-1);
		connections.add(newPriority-1, item);

		System.out.println("updating priority. was" + oldPriority + " now is " + newPriority);

		update_all_priorities();
		reload_connections_gui();
	}

	//creates a "anything else" connection to next_state
	void connect(State next_state) {
		this.connect(new Expression("true"), next_state);
	}

	//creates a "anything else" connection to self
	void connect_anything_else_to_self() {
		this.connect(this);
	}

	boolean there_is_already_a_connection_to_state(State next) {
		boolean result = false;

		for (Connection c : connections)
			if (next==c.get_next_state()) result = true;

		return result;
	}

	//remove a connection from this state
	void disconnect(Connection c) {
		if (connections.contains(c)) {
			//all connection gui items
			c.remove_gui_items();
			//remove the connection
			this.connections.removeElement(c);

			//if there is only one connection left and it is a trnsition to self
			//if (this.connections.size()==1 && this.connections.get(0).get_next_state()==this)
				//removes everything
			//	this.disconnect(this.connections.get(0));

			//updates priorities of connections
			this.update_all_priorities();
		} else
			if (debug)
				System.out.println("Unable to remove connection " + c.toString() + " from state " + this.name);
	}

	int get_number_of_tasks() {
		return this.tasks.size();
	}

	//method that generates a random name for the demo task
	String generate_random_name() {
		return ("example" + ((int)p.random(0, 100)));
	}


	//method that initializes a random demo osc task
	void init_random_osc_task () {
		String taskname = generate_random_name();
		OSCTask t = new OSCTask(p, cp5, taskname, "/test/value", 12000, "localhost", new Object[]{0, 12});
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}

	//method that initializes a random demo audio task
	void init_random_audio_task () {
		String taskname = generate_random_name();
		AudioTask t = new AudioTask(p, cp5, taskname, "123go.mp3");
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}

	//method that initializes a random demo state machine task
	void init_random_state_machine_task () {
		String taskname = generate_random_name();
		StateMachine t = new StateMachine(p, cp5, taskname);
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}

	//method that initializes a random demo set balckboard task
	void init_random_set_blackboard_task () {
		String taskname = generate_random_name();
		SetBBTask t = new SetBBTask(p, cp5, taskname, 0);
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}

	/////////////////////////////
	// special remote tasks
	void init_start_audio_task() {
		String taskname = generate_random_name();
		StartRemoteSoundTask t = new StartRemoteSoundTask(p, cp5, taskname);
		this.add_task(t);
	}

	void init_control_audio_task() {
		String taskname = generate_random_name();
		ControlRemoteSoundTask t = new ControlRemoteSoundTask(p, cp5, taskname);
		this.add_task(t);
	}

	void init_stop_audio_task() {
		String taskname = generate_random_name();
		StopRemoteSoundTask t = new StopRemoteSoundTask(p, cp5, taskname);
		this.add_task(t);
	}

	void init_start_aura_task() {
		String taskname = generate_random_name();
		StartRemoteAuraTask t = new StartRemoteAuraTask(p, cp5, taskname);
		this.add_task(t);
	}

	void init_control_aura_task() {
		String taskname = generate_random_name();
		ControlRemoteAuraTask t = new ControlRemoteAuraTask(p, cp5, taskname);
		this.add_task(t);
	}

	void init_stop_aura_task() {
		String taskname = generate_random_name();
		StopRemoteAuraTask t = new StopRemoteAuraTask(p, cp5, taskname);
		this.add_task(t);
	}

	void init_start_dmx_task() {
		String taskname = generate_random_name();
		StartRemoteDMXTask t = new StartRemoteDMXTask(p, cp5, taskname);
		this.add_task(t);
	}

	void init_control_dmx_task() {
		String taskname = generate_random_name();
		ControlRemoteDMXTask t = new ControlRemoteDMXTask(p, cp5, taskname);
		this.add_task(t);
	}

	void init_stop_dmx_task() {
		String taskname = generate_random_name();
		StopRemoteDMXTask t = new StopRemoteDMXTask(p, cp5, taskname);
		this.add_task(t);
	}

	//method that initializes a random demo osc task
	void init_osc_task () {
		String taskname = generate_random_name();
		OSCTask t = new OSCTask(p, cp5, taskname, "/test/value", ((ZenStates)p).get_remote_port(), ((ZenStates)p).get_remote_ip(), new Object[]{0});
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}
	
	//method that initializes a state machine task
	void init_state_machine_task () {
		String taskname = generate_random_name();
		StateMachine t = new StateMachine(p, cp5, taskname);
		this.add_task(t);
	}
	

	//method that initializes a scripting task
	void init_scripting_task () {
		String taskname = generate_random_name();
		ScriptingTask t = new ScriptingTask(p, cp5, "example.js");
		this.add_task(t);
	}
	

	//method that initializes a random demo set balckboard task
	void init_set_blackboard_task () {
		String taskname = generate_random_name();
		SetBBTask t = new SetBBTask(p, cp5, taskname, 0);
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}

	//method that initializes a random osc balckboard var
	void init_bb_osc_task () {
		String taskname = generate_random_name();
		SetBBOscillatorTask t = new SetBBOscillatorTask(p, cp5);
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}

	//method that initializes a random balckboard var
	void init_bb_rand_task () {
		String taskname = generate_random_name();
		SetBBRandomTask t = new SetBBRandomTask(p, cp5);
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}

	//method that initializes a ramp balckboard var
	void init_bb_ramp_task () {
		String taskname = generate_random_name();
		SetBBRampTask t = new SetBBRampTask(p, cp5);
		this.add_task(t);
		//println(selected + " " + pie.options[selected]);
	}


	int get_number_of_connections() {
		return connections.size();
	}


	/*******************************************
	 ** GUI FUNCTIONS ***************************
	 ********************************************/
	void draw() {
		draw_temp_connection();
		update_gui();
		draw_connections();
		draw_pie();
		draw_state();
		//animation.draw();
		//draw_gui();
	}
	
	/*
	void draw_gui() {
		//draw this cp5 elements
		label.draw(p.g);
		
		
		accordion.draw(p.g);
		//draw cp5 elements of the tasks
		for (Task t : tasks) 
			t.draw_gui();
		for (Connection c : connections) 
			c.draw_gui();
		
	}
	*/

	//updates the current position of this state in screen
	void set_position_gui(int newx, int newy) {
		this.x = newx;
		this.y = newy;
		this.pie.set_position(x, y);
		//this.animation.set_position(x, y);
		//disables the focus
		//label.setFocus(false);
	}

	//checks if a certain position (often the mouse) intersects this state in the screen
	boolean intersects_gui(int test_x, int test_y) {
		int dx = p.abs(test_x-x);
		int dy = p.abs(test_y-y);
		int R = size-25;

		return (dx*dx)+(dy*dy) <= R*R;
	}

	//functions that updates the gui
	void update_gui() {
		//verifies if the user picked an option in the pie menu
		verify_if_user_picked_a_pie_option();
		//removes the task, if necessary
		remove_task_in_gui_if_necessary();
		//updates the gui cordinates, if necessary
		update_cordinates_gui();
		//update connecitons gui
		//update_connections_gui();
		remove_connection_if_necessary();
	}

	//aux variable to handle the state moving on the screen
	//boolean moving = false;

	//updates the coords of the state in the screen in case mouse drags it
	void update_cordinates_gui() {
		//if mouse if moving
		if (p.mousePressed) {
			//if intersects for the first time
			if (this.intersects_gui(p.mouseX, p.mouseY) && !is_dragging_someone && this.movement_status==MovementStatus.FREE) {
				//set move equals true
				//moving= true;
				//movement_status = MovementStatus.MOVING;
				//is_dragging_someone = true;
				this.start_gui_dragging();
			}

			//if is moving, updates the value
			if (movement_status==MovementStatus.MOVING)
				set_position_gui(p.mouseX, p.mouseY);
			//if mouse is released
		} else {
			//if this state was moving before
			if (movement_status==MovementStatus.MOVING) {
				//stops moving
				//movement_status = MovementStatus.FREE;
				//is_dragging_someone = false;
				this.stop_gui_dragging();
			}
		}
	}
	
	void start_gui_dragging() {
		movement_status = MovementStatus.MOVING;
		is_dragging_someone = true;
	}
	
	void stop_gui_dragging() {
		movement_status = MovementStatus.FREE;
		is_dragging_someone = false;
	}

	void remove_all_connections () {
		for (int i = connections.size()-1; i >=0; i--) {
			Connection c = connections.get(i);
			this.disconnect(c);
			this.reload_connections_gui();
		}
	}

	void remove_connection_if_necessary() {
		for (int i = connections.size()-1; i >=0; i--) {
			Connection c = connections.get(i);
			if (c.should_be_removed()) {
				System.out.println("remove "+ c.toString());
				this.disconnect(c);
				this.reload_connections_gui();
			}
		}

	}

	//updates the name of this state
	void update_name (String newName) {
		//ControlP5 cp5 = HFSMPrototype.instance().cp5();
		//removes the old gui label
		cp5.remove(this.name);
		//removes all tasks from the gui
		this.remove_all_tasks_from_gui();
		//remove all connections ui elements
		this.remove_gui_connections_involving_this_state();
		//updates the name
		this.name = newName.toUpperCase();
		//creates a new gui element for it
		this.init_state_name_gui();
		//adds all tasks with the updated name
		this.add_all_tasks_to_gui();
		//add all connections ui elements
		this.init_gui_connections_involving_this_state();
	}

	//resets the name of this state
	void reset_name () {
		//iterates of all tasks related to this state
		for (Task t : tasks)
			t.reset_gui_fields();

		//this.update_name(this.name);
		//p.println("reseting name: " + this.label.getText());
		this.update_name(this.label.getText());
	}

	//inits gui elements related to controlP5
	void init_gui() {
		//this.pie = new PieMenu(p, x, y, size);
		this.pie = new MultiLevelPieMenu(p);
		this.pie.set_position(x,y);
		this.pie.set_inner_circle_diam((float)size);
		
	    //this.animation = new CircleEffectUI((ZenStates)p, this, x, y);
	    //this.animation.set_position(x,y);
	    
		//ControlP5 cp5 = HFSMPrototype.instance().cp5();

		p.textSize(cp5.getFont().getSize());
		p.textFont(cp5.getFont().getFont());
		init_state_name_gui();
		init_accordion_gui();
		//init_tasks_gui();
		
		add_all_tasks_to_gui();
		
		for (Connection c:connections) 
			c.init_gui_items();
	}

	void hide_gui() {
		//if the PApplet wasn't loaded yet
		if (label==null||accordion==null)return;

		label.hide();
		accordion.hide();
	
		for (Connection c:connections) 
			c.hide();
	}

	void show_gui() {
		//if the PApplet wasn't loaded yet
		if (label==null||accordion==null)
			return;
		label.show();
		accordion.show();
		
		for (Connection c:connections) 
			c.show();
	}

	boolean is_textfield_selected = false;

	CallbackListener generate_callback_enter() {
		return new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {

				//if this textfield is not selected, returns...
				//if (label.getText().equalsIgnoreCase(newName))
				//if (!label.isFocus()) return;

				//if the name is empty, resets
				if (label.getText().trim().equalsIgnoreCase("")) label.setText(name);
				//if the name didn't change, no need to continue
				if (label.getText().equalsIgnoreCase(name)) return;

				String newName = theEvent.getController().getValueLabel().getText();
				String oldName = name;

				update_name(newName);
				/*
            MainCanvas canvas = HFSMPrototype.instance().canvas;

            //checks if there is already a state with the very same future name [BAD CODE!]
            State is_there_a_state_with_the_new_id = canvas.root.get_state_by_name(newName);
            State result                             = canvas.root.get_state_by_name(oldName);

            //if there is, prints an error and change does not occur!
            if (is_there_a_state_with_the_new_name != null) {
              System.out.println("There is alrealdy a state with this same name. Please, pick another name!");
              //if the names are different, reset
              if (!oldName.equals(newName))
                result.update_name(oldName);
              return;
            }

            if (result != null)

              result.update_name(newName);
            else
              System.out.println("a state with name " + oldName + " could not be found! ");
				 */
			}
		};
	}


	CallbackListener generate_callback_leave() {
		return new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {
				//if the user leaves the textfield without pressing enter
				if (!label.getText().equalsIgnoreCase(name))
					//resets the label
					//init_state_name_gui();
					reset_name();
			}
		};
	}
	
	/*
	CallbackListener generate_callback_double_press() {
		return new CallbackListener() {
			public void controlEvent(CallbackEvent theEvent) {
				
				p.println("double clicked on "  + name);
			}
		};
	}
	*/


	//inits the label with the name of the state
	void init_state_name_gui() {

		//ControlP5 cp5 = HFSMPrototype.instance().cp5();

		CallbackListener cb_enter = generate_callback_enter();
		//CallbackListener cb_leave = generate_callback_leave();

		int c1 = p.color(255, 255, 255, 255);
		int c2 = p.color(0, 0, 0, 1);

		label = cp5.addTextfield(this.id+"/label")
				.setText(this.name)
				.setVisible(true)
				.setLabelVisible(true)
				.setColorValue(c1)
				.setColorBackground(c2)
				.setColorForeground(c2)
				//.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER)
				.setWidth((int)(p.textWidth(this.name)*1.25))
				.setFocus(false)
				.setAutoClear(false)
				.setLabel("")
				.onChange(cb_enter)
				.onReleaseOutside(cb_enter)
				//.onDoublePress(generate_callback_double_press())
				//.onDrag(cb)
				;
	}

	//init the accordion that will store the tasks
	void init_accordion_gui() {
		//ControlP5 cp5 = HFSMPrototype.instance().cp5();

		//accordion = cp5.addAccordion("acc_"+this.name)
		accordion = cp5.addAccordion(this.id+"/acc")
				.setWidth(110)
				.setVisible(true)
				//.hide()
				;
	}

	//adds a task from the accordion
	void add_task_in_accordion_gui(Task t) {

		//creates a new group
		Group g = t.load_gui_elements(this);
		
		//sets it visible
		g.setVisible(true);

		//adds this group to the accordion
		accordion.addItem(g);
	}

	//removes a task from the accordion
	void remove_task_in_accordion_gui(Task t) {
		//ControlP5 cp5 = HFSMPrototype.instance().cp5();
		//looks for the group
		//Group g = cp5.get(Group.class, this.name + " " + t.get_name());
		//removes this task from the accordion
		if (t==null || cp5==null) {
			p.println("OPPPAAAAAAA!!!! NULL POINTER!!!! WTF!!!!");
			return;
		}
		p.println("removing task " + t.get_gui_id());
		cp5.getGroup(t.get_gui_id()).remove();
		//cp5.getGroup(this.name + " " + t.get_name()).remove();
	}

	//draws the status of this state
	void draw_status() {
		p.noStroke();

		if (is_actual)
		//if (status==Status.RUNNING)
			//if (status==Status.RUNNING | (status==Status.DONE & is_actual))
			p.fill (0, green+75, 0);
		else if (status==Status.DONE)
			p.fill (100, 0, 0);
		else if (status==Status.INACTIVE)
			p.fill (100);

		p.ellipse(x, y, size+25, size+25);

		//increments the status
		increment_status();
	}

	//aux variables for the gui
	float counter = 0, green = 0;

	void increment_status() {
		//incrementing the counter
		int limit = 32;
		if (counter < limit/2)
			green = green+limit/16;
		else
			green = green-limit/16;

		counter=(counter+1)%limit;
	}

	void draw_state() {
		//if keypressed, draws a connection
		//if (keyPressed)
		// draw_connections(mouseX, mouseY);

		//draws the status circle
		draw_status();

		//draws the main central ellipse
		p.noStroke();
		p.fill (0);
		p.ellipse(x, y, size, size);

		//prints info such as tasks and name
		move_gui();
	}

	void move_gui() {
		//moving the label
		label.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER);
		float textwidth = p.textWidth(name);
		textwidth = textwidth/2;
		label.setPosition(x-textwidth-(textwidth/5), y-7);


		//moving the tasks
		accordion.setPosition(x-(accordion.getWidth()/2), y+(size/2)+(size/4));
	}

	//draws additional info if this is a begin
	void draw_begin() {

		p.noFill();
		//stroke(green+25);
		p.stroke(50);
		//the wieght of the line
		p.strokeWeight(5);
		p.ellipse(x, y, size*2, size*2);
		//fill(green+25);
		p.fill(50);
		p.noStroke();
		p.textAlign(p.CENTER, p.CENTER);
		p.text("BEGIN", x, y-(size*1.2f));
	}

	//draws additional info if this is an end
	void draw_end() {
		//line color
		p.noFill();
		//stroke(green+25);
		p.stroke(50);
		//the wieght of the line
		p.strokeWeight(5);
		p.ellipse(x, y, size*2, size*2);
		//fill(green+25);
		p.fill(50);
		p.noStroke();
		p.textAlign(p.CENTER, p.CENTER);
		p.text("END", x, y-(size*1.2f));
	}

	//draws additional info if this is an end
	void draw_actual() {
		//line color
		p.noFill();
		p.stroke(green+25);
		//stroke(50);
		//the wieght of the line
		p.strokeWeight(5);
		p.ellipse(x, y, size*2.5f, size*2.5f);
		p.fill(green+25);
		//fill(50);
		p.noStroke();
		p.textAlign(p.CENTER, p.CENTER);
		p.text("ACTUAL", x, y-(size*1.5f));
	}

	void draw_connections () {
		for (int i = 0; i < connections.size(); i++) {
			Connection c = connections.get(i);
			c.update_priority(i+1);
			//if (c.get_next_state().get_name() == this.get_name())
			//	draw_connection_to_self(c);
			//else
				draw_connection(c);
		}
	}

	boolean there_is_a_temporary_connection_on_gui () {
		return (this.movement_status==MovementStatus.FREEZED);
	}

	boolean verify_if_user_released_mouse_while_temporary_connecting () {
		return (there_is_a_temporary_connection_on_gui() && ZenStates.instance().mouseReleased);
	}

	void draw_temp_connection() {
		//if this state is freezed
		if (there_is_a_temporary_connection_on_gui()) {
			draw_generic_connection(p.mouseX, p.mouseY, connections.size()+1, "true");
		}
	}

	void draw_generic_connection (int destx, int desty, int priority, String label) {
		draw_generic_connection(destx, desty, priority, label, true);
	}

	void draw_generic_connection (int destx, int desty, int priority, String label, boolean print_label) {
		//line color
		p.stroke(50);
		//the wieght of the line
		p.strokeWeight(size/10);
		//draws the line
		p.line(x, y, destx, desty);
		//saves the current matrix
		p.pushMatrix();
		//moving to where the arrow is going
		p.translate(x, y);
		//saves the current matrix
		p.pushMatrix();
		//computes the midpoint where the arrow is going to be
		float newx = ((destx-x)/2)*arrow_scale_offset;
		float newy = ((desty-y)/2)*arrow_scale_offset;
		//translate to the final position of the arrow
		p.translate(newx, newy);

		//saves the current matrix
		p.pushMatrix();

		//computes the angle to rotate the arrow
		float a = p.atan2(x-destx, desty-y);
		//rotates
		p.rotate(a);
		//draws the arr0w
		//p.line(0, 0, -10, -10);
		//p.line(0, 0, 10, -10);
		p.line(0, 0, -10, -10);
		p.line(0, 0, 10, -10);
		//returns the matris to the regular position
		p.popMatrix();
		//sets text color
		p.fill(180);
		p.textAlign(p.CENTER, p.CENTER);
		if(print_label)
			p.text("[ "+priority+" ] : " + label, 0, -30);
		//c.set_gui_position(0, -30);
		//returns the matris to the regular position
		p.popMatrix();
		p.popMatrix();
	}

	void draw_connection (Connection c) {
		State ns = c.get_next_state();
		float destx = ns.x;
		float desty = ns.y;
		draw_generic_connection(ns.x, ns.y, c.get_priority(), c.get_expression().toString(), false);
		//float newx = ((destx-x)/2);
		//float newy = ((desty-y)/2)
		float newx = ((destx-x)/2)*arrow_scale_offset;
		float newy = ((desty-y)/2)*arrow_scale_offset;
		float a = p.atan2(destx-x, desty-y);
		newx = (newx+x);
		newy = (newy+y);
		int x_offset = (int)c.get_label_width()/2;
		c.set_gui_position((int)newx-x_offset, (int)newy-30);
	}

	void draw_connection_to_self(Connection c) {
		//line color
		p.stroke(50);
		//the wieght of the line
		p.strokeWeight(size/10);
		//draws the lines
		p.line(x, y, x-100, y-100);
		p.line(x, y, x+100, y-100);
		p.line(x-100, y-100, x+100, y-100);
		//draw the arrow
		p.line(x-5, y-100, x+5, y-90);
		p.line(x-5, y-100, x+5, y-110);
		//draw the input
		p.fill(180);
		//textAlign(CENTER, CENTER);
		//text("[ "+priority+" ] : "  + c.get_expression().toString(), x, y-125);
		int x_offset = (int)c.get_label_width()/2;
		c.set_gui_position(x-x_offset, y-125);
	}

	void draw_pie() {
		pie.draw();
	}
	//show the attached pie
	void show_pie() {
		pie.show();
	}

	//close the attached pie
	void hide_pie() {
		pie.hide();
	}

	//gets what option of the pie has been selected. returns -1 if none is selected
	int get_pie_option() {
		return pie.get_selection();
	}

	//returns if the pie menu is currently open or not
	boolean is_pie_menu_open () {
		return (pie.is_showing()&&(!pie.is_fading_away()));
	}

	//boolean

	//verifies if the user selected a option inside the pie menu
	void verify_if_user_picked_a_pie_option() {
		//if the menu is not open or the mouse is not clicked, returns
		if (!is_pie_menu_open() || !p.mousePressed) return;

		int selected = get_pie_option();

		//if the mouse is pressed & the button is over a option & is not dragging
		if (p.mousePressed && selected > -1 && !is_dragging_someone) {
			p.println("state receive " + selected + " as a result");

			switch(selected) {
			//case 0:
			//  init_random_set_blackboard_task();
			//  hide_pie();
			//  break;
			//case 7:
			//  init_osc_task();
			//  hide_pie();
			//  break;
			case 12:
				init_start_audio_task();
				hide_pie();
				break;
			case 13:
				init_control_audio_task();
				hide_pie();
				break;
			case 10:
				init_stop_audio_task();
				hide_pie();
				break;
			case 22:
				init_start_aura_task();
				hide_pie();
				break;
			case 23:
				init_control_aura_task();
				hide_pie();
				break;
			case 20:
				init_stop_aura_task();
				hide_pie();
				break;
			case 32:
				init_start_dmx_task();
				hide_pie();
				break;
			case 33:
				init_control_dmx_task();
				hide_pie();
				break;
			case 30:
				init_stop_dmx_task();
				hide_pie();
				break;
			case 43:
				init_bb_rand_task();
				hide_pie();
				break;
			case 44:
				init_bb_osc_task();
				hide_pie();
				break;
			case 45:
				init_bb_ramp_task();
				hide_pie();
				break;
			case 40:
				init_set_blackboard_task();
				hide_pie();
				break;
			case 52:
				init_state_machine_task();
				hide_pie();
				break;
			case 53:
				init_scripting_task();
				hide_pie();
				break;
			case 50:
				//init_script_task();
				init_osc_task();
				hide_pie();
				break;
			}

			/*
      hide_pie();
      println(pie.options[selected] + " (option " + selected + ") selected in state " + this.name);
      switch(selected) {
        case 0: //StateMachine
          init_random_state_machine_task();
          break;
        case 3: //SetBlackboard
          init_random_set_blackboard_task();
          break;
        case 4: //Audio
          init_random_audio_task();
          break;
        case 5: //OSC
          init_random_osc_task();
          break;
        }
			 */
		}
	}

	//verifies if the mouse is over a certain task, returning this task
	Task verifies_if_mouse_is_over_a_task () {
		Task to_be_removed = null;
		//ControlP5 cp5 = HFSMPrototype.instance().cp5();

		//iterates of all tasks related to this state
		for (Task t : tasks) {
			//gets the group related to this task
			Group g = cp5.get(Group.class, t.get_gui_id());

			if (g==null) {
				p.println("g==null");
				return null;
			}

			//verifies if the menu item is selected and the user pressed '-'
			if (g.isMouseOver() && ZenStates.instance().user_pressed_minus ()) {
				//stores the item to be removed
				to_be_removed = t;
				break;
			}
		}

		return to_be_removed;
	}

	void remove_task_in_gui_if_necessary () {
		Task to_be_removed = verifies_if_mouse_is_over_a_task();
		//if there is someone to be removed
		if (to_be_removed!=null)
			//removes this item
			remove_task(to_be_removed);
	}

	//removes all tasks from the gui (used whenever the state name needs to change)
	void remove_all_tasks_from_gui () {
		//iterates of all tasks related to this state
		for (Task t : tasks)
			remove_task_in_accordion_gui(t);
	}
	
	//resets the group i all tasks to the gui (used whenever the state name needs to change)
	void reset_group_id_gui_of_all_tasks () {
		//iterates of all tasks related to this state
		for (Task t : tasks) 
			t.reset_group_id();
		
	}

	//adds all tasks to the gui (used whenever the state name needs to change)
	void add_all_tasks_to_gui () {
		//iterates of all tasks related to this state
		for (Task t : tasks) 
			add_task_in_accordion_gui(t);
	}

	void freeze_movement_and_trigger_connection() {
		System.out.println("freezing " + this.name);
		this.movement_status = MovementStatus.FREEZED;
		label.setFocus(false);
	}

	void unfreeze_movement_and_untrigger_connection() {
		if(this.movement_status == MovementStatus.FREEZED) {
			System.out.println("unfreezing " + this.name);
			this.movement_status = MovementStatus.FREE;
		}
	}

	void remove_gui_connections_involving_this_state() {
		//removing the connections originated in this state
		for (Connection c : connections)
			c.remove_gui_items();

		ZenStates.instance().canvas().root.remove_all_gui_connections_to_a_state(this);
	}
	

	void remove_all_gui_connections_to_a_state (State dest) {
		//iterating over connections backwards
		for (int i = connections.size()-1; i >=0 ; i--) {
			Connection c = connections.get(i);
			if (c.get_next_state()==dest)
				c.remove_gui_items();
		}
	}
	
	void remove_all_gui_items () {
		//iterating over connections backwards
		for (int i = connections.size()-1; i >=0 ; i--) {
			Connection c = connections.get(i);
			c.remove_gui_items();
		}
		
		this.remove_all_tasks_from_gui();
		
		cp5.remove(this.id+"/label");
		cp5.remove(this.id+"/acc");
	
		//this.pie = new MultiLevelPieMenu(p);
		
		
		
	}


	void init_gui_connections_involving_this_state() {
		//initing the connections originated in this state
		for (Connection c : connections)
			c.init_gui_items();

		ZenStates.instance().canvas().root.init_all_gui_connections_to_a_state(this);
	}

	void init_all_gui_connections_to_a_state (State dest) {
		//iterating over connections backwards
		for (int i = connections.size()-1; i >=0 ; i--) {
			Connection c = connections.get(i);
			if (c.get_next_state()==dest)
				c.init_gui_items();
		}
	}

}
