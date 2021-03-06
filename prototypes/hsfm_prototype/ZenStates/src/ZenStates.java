/************************************************
 ** My main!
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/



import processing.core.PApplet;
import oscP5.*;
import java.io.File;
import java.math.BigDecimal;
import java.util.Vector;

import javax.script.*;

import controlP5.*;
import ddf.minim.*;

import java.awt.event.KeyEvent;


public class ZenStates extends PApplet {

	MainCanvas canvas;
	Blackboard board;
	Serializer serializer = new Serializer(this);
			
	OscP5 		oscP5; 	//my osc variables
	ControlP5 	cp5;	//my controlP5 variable for gui
	Minim       minim;	//my minim variable

	//system's default port for receiveing osc messages
	String SERVER_IP;
	int    SERVER_PORT;
	int    OSC_RECV_PORT;
	int    STATE_CIRCLE_SIZE;
	int    FONT_SIZE;

	boolean debug 			= false;
	boolean keyReleased   	= false;
	boolean mouseRightButtonReleased 	= false;
	boolean is_loading 		= false;

		
	public static void main(String[] args) {
        PApplet.main("ZenStates");
    }
	
	public void settings() {
	    //fullScreen();
		size(800, 600);
	}
	
	public void setup() {
		setup_util();
		is_loading = true;
		background(0);
		smooth();
		inst = this;
		board  = new Blackboard(this);
		canvas = new MainCanvas(this, cp5);

		setup_expression_loading_bug();

		textFont(cp5.getFont().getFont());
		textSize(FONT_SIZE);
		
		//testing autodraw
		//cp5.setAutoDraw(false);

		is_loading = false;
	}

	//solves the freezing problem when loading the first expression
	void setup_expression_loading_bug() {
		Expression test = new Expression("0");
		try {
			((Expression)test).eval(board);
		}
		catch (ScriptException e) {
			System.out.println("ScriptExpression thrown, unhandled update.");
		}
	}

	public void draw() {
		background(0);

		//if is loading an open patch, do not draw anything
		if (is_loading) {
			fill(255);
			textAlign(CENTER);
			text("loading... please, wait.", width/2, height/2);
			return;
		}


		//updates global variables in the bb
		board.update_global_variables();
		//draws the scenario
		canvas.draw();
		//draws the blackboard
		board.draw();

		if (keyReleased)     keyReleased = false;
		if (mouseRightButtonReleased) mouseRightButtonReleased = false;

		serializer.autosave();
	}



	//////////////////////////////////////
	// UTIL FUNCTIONS

	//calls all other utils
	void setup_util() {
		load_config();
		setup_osc();
		setup_control_p5();
		setup_minim();
	}
	
	//function for setting up osc
	void setup_osc () {
		// start oscP5, listening for incoming messages.
		oscP5 = new OscP5(this, OSC_RECV_PORT);
	}

	//function for setting up controlp5
	void setup_control_p5 () {
		cp5 = new ControlP5(this);
		cp5.setFont(cp5.getFont().getFont(), FONT_SIZE);
	}

	//sets the minim up
	void setup_minim() {
		minim = new Minim(this);
	}

	//rounds a float to two decimals for the gui
	//retrieved from: http://stackoverflow.com/questions/8911356/whats-the-best-practice-to-round-a-float-to-2-decimals#8911683
	public static BigDecimal round(float d, int decimalPlace) {
		BigDecimal bd = new BigDecimal(Float.toString(d));
		bd = bd.setScale(decimalPlace, BigDecimal.ROUND_HALF_UP);
		return bd;
	}

	void oscEvent(OscMessage msg) {
		if (debug) {
			System.out.println("### received an osc message.");
			System.out.println(" addrpattern: "+msg.addrPattern());
			System.out.println(" typetag: "+msg.typetag());
		}

		board.oscEvent(msg);

	}

	
	void load_config() {
	
	  String lines[] = loadStrings(sketchPath() + "/data/config.txt");
	  Vector<String> params = new Vector<String>();
	
	  for (int i = 0 ; i < lines.length; i++)
	    if (!lines[i].trim().startsWith("#")) params.add((String)lines[i]);
	
	  if (debug) {
	    println("SERVER IP: " + params.get(0));
	    println("SERVER PORT: " + params.get(1));
	    println("INCOMING OSC PORT: " + params.get(2));
	    //println("FULLSCREEN: " + params.get(3));
	    println("STATE CIRCLE SIZE: " + params.get(3));
	    println("FONT SIZE: " + params.get(4));
	  }
	
	  SERVER_IP    		= params.get(0);
	  SERVER_PORT   	= Integer.parseInt(params.get(1));
	  OSC_RECV_PORT		= Integer.parseInt(params.get(2));
	  STATE_CIRCLE_SIZE = Integer.parseInt(params.get(3));
	  FONT_SIZE = Integer.parseInt(params.get(4));
	  
	}
	
	///////////////////////////////////////
	// ui related methods
	
	public boolean cmg_or_ctrl_pressed = false;
	public boolean should_copy 		   = false;
	
	public void keyPressed(){
		//if (debug)
		println("keyCode: " + keyCode + " key: " +key);
		
		//if is loading an open patch, do not draw anything
		if (is_loading) return;
			
		//updating cmg_or_ctrl_pressed if contrll or command keys were pressed
		if (keyCode == 17 || keyCode == 27 || keyCode == 157)
			cmg_or_ctrl_pressed = true;
		
		//if control or command key are not pressed, ignore
		if (!cmg_or_ctrl_pressed) return;
			
		switch(keyCode) {
		case 61: //+
			//create_state();
			canvas.process_plus_key_pressed();
			break;
		case 45: //-
			//remove_state();
			canvas.process_minus_key_pressed();
			break;
		case 32: //spacebar
			if (canvas.is_running()) canvas.button_stop();
			else					 canvas.button_play();
			break;	
		case 83: //s
			canvas.button_save();
			break;
		case 76: //l
			canvas.button_load();
			break;
		}
		//println(keyCode);
	}

	public void mousePressed() {
		//if is loading an open patch, do not draw anything
		if (is_loading) return;
		
		if (mouseButton == RIGHT) 
			canvas.process_right_mouse_button();
			//canvas.process_shift_key();
		
		if (mouseButton == LEFT) {			
			//if the key is not pressed, i'm not interested
			if (!keyPressed) return;
		
			switch(keyCode) {
			//in case the key it's shift
			case 16:
				canvas.process_shift_key();
				break;
			//if alt key was pressed
			case 18:
				canvas.process_copy();
				break;
			}
			
		}
	}
	
	
	public void mouseDragged () {
		if (mouseButton == RIGHT) 
			canvas.start_dragging_connection();
	}
	

	public void keyReleased() {
		keyReleased = true;
		
		//updating cmg_or_ctrl_pressed if contrll or command keys were pressed
		if (keyCode == 17 || keyCode == 27 || keyCode == 157)
			cmg_or_ctrl_pressed = false;
	}

	public void mouseReleased() {
		if (mouseButton == RIGHT) 
			mouseRightButtonReleased = true;
	}

	//checks if the user released the key minus
	public boolean user_pressed_minus () {
		boolean result = keyReleased && key=='-';
		//returns the result
		return result;
	}

	///////////////////////////////////////////////////
	//the following code was taken from Sofians' prototype
	//the goal is to allow serialization

	public OscP5 oscP5() { return oscP5; }
	public ControlP5 cp5() { return cp5; }
	public Minim minim() { return minim; }
	public Blackboard board() { return board; }
	public MainCanvas canvas() { return canvas; }
	public boolean debug() { return debug; }
	public String get_remote_ip() { return SERVER_IP;}
	public int get_remote_port() { return SERVER_PORT; }
	public int get_state_circle_size() { return STATE_CIRCLE_SIZE; }
	public int get_font_size() { return FONT_SIZE; }

	private static ZenStates inst;

	public static ZenStates instance() {
		return inst;
	}
}
