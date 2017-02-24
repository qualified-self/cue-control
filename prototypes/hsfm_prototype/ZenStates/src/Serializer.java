/******************************************************
 ** Class that implements file saving/loading *********
 ******************************************************
 ** this code was written by Sofian and incorporated *
 ** into my prototype in DEc. 1st *********************
 *****************************************************/
import java.io.*;
import processing.core.PApplet;


public class Serializer {

	ZenStates p;
	
	//variable to handle autosave
	int autosavetime = 1; //minutes
	int timestamp;
	File autosave_file;

	Serializer(ZenStates p) {
		this.p = p;
		setup_autosave();
	}

	File lastSaveFile = null;

	void save() {
		if (lastSaveFile == null)
			saveAs();
		else
			_saveAs(lastSaveFile);
	}
	
	void saveAs() {
		p.selectOutput("Select file: ", "_saveAs", lastSaveFile, this);
	}

	void load() {
		p.selectInput("Select file: ", "_load", lastSaveFile, this);
	}
	
	boolean check_if_file_exists_in_sketchpath (String name) {
		File f = new File(p.sketchPath()+"/data/patches/"+name);
		return f.exists();
	}
	
	public void delete (String name) {
		File f = new File(p.sketchPath()+"/data/patches/"+name);
		if (f.exists()) f.delete();
	}
	
	public File returnFileTosave(File f) {
		return f;
	}
	
	void setup_autosave() {
		timestamp     = p.minute();
		autosave_file = new File(p.sketchPath() + "/data/patches/temp.zen");
		p.println(p.sketchPath());
	}

	void autosave() {
		int time_elapsed = p.abs(p.minute()-timestamp);

		if (time_elapsed > autosavetime) {
			_saveAs(autosave_file, p.canvas.root, false);
			p.println("saving!");
			timestamp = p.minute();
		}
	}
	
	public void _saveAs(File file) {
		_saveAs(file, p.canvas.root, true);
		lastSaveFile = file;
	}
	
	public void _saveAs (String filename, StateMachine sm) {
		File f = new File(p.sketchPath()+"/data/patches/"+filename);
		_saveAs(f, sm, true);
	}

	public void _saveAs(File file, StateMachine sm, boolean should_rename) {
		if (file == null)
			return;
		try {
			//renames if necessary
			if (should_rename)
				sm.update_title(file.getName());
			ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file));
			//oos.writeObject(p.board());
			//oos.writeObject(p.canvas());
			oos.writeObject(sm);
			oos.close();
		} catch (Exception e) {
			p.println("ERROR saving to file: " + file + " [exception: " + e.toString() + "].");
			e.printStackTrace();
		}
	}
	
	
	public StateMachine loadSubStateMachine (String filename) {
		
		File file = new File(p.sketchPath()+"/data/patches/"+filename);
		
		//if the file does not exist, return null!
		if (!file.exists()) return null;
		
		StateMachine result = null;

		try {	
			ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));
			result = (StateMachine) ois.readObject();
			result.build(p, p.cp5);
			ois.close();
			
		} catch (Exception e) {
			p.println("ERROR loading sub-statemachine: " + file + " [exception: " + e.toString() + "].");
			e.printStackTrace();
			//p.board  = new Blackboard(p);
			//p.canvas = new MainCanvas(p, p.cp5);
		}

		return result;
	}
	

	public void _load(File file) {
		
		try {	
			p.is_loading = true;
			p.canvas.root.hide();
			p.cp5.setAutoDraw(false);

			ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));
			
			//p.board.clear();
			p.canvas.clear();

			//p.board    = (Blackboard) ois.readObject();
			//p.canvas   = (MainCanvas) ois.readObject();
			p.canvas.setup((StateMachine) ois.readObject());
			
			lastSaveFile = file;
			ois.close();

		} catch (Exception e) {
			p.println("ERROR loading file: " + file + " [exception: " + e.toString() + "].");
			e.printStackTrace();
			//p.board  = new Blackboard(p);
			//p.canvas = new MainCanvas(p, p.cp5);
			p.canvas.setup();
		}

		p.cp5.setAutoDraw(true);
		p.is_loading = false;

		p.println("done loading!");
	}
	
	

}
