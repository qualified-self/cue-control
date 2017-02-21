/******************************************************
 ** Class that implements file saving/loading *********
 ******************************************************
 ** this code was written by Sofian and incorporated *
 ** into my prototype in DEc. 1st *********************
 *****************************************************/
import java.io.*;
import processing.core.PApplet;


public class Serializer {

	PApplet p;

	Serializer(PApplet p) {
		this.p = p;
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

	public void _saveAs(File file) {
		if (file == null)
			return;
		try {
			ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file));
			oos.writeObject(ZenStates.instance().board());
			oos.writeObject(ZenStates.instance().canvas());
			oos.close();
		} catch (Exception e) {
			p.println("ERROR saving to file: " + file + " [exception: " + e.toString() + "].");
			e.printStackTrace();
		}
	}

	public void _load(File file) {
		ZenStates inst = ZenStates.instance();
		
		try {	
			inst.is_loading = true;
			inst.canvas.root.hide();
			inst.cp5.setAutoDraw(false);

			ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));
			inst.board.clear();
			inst.canvas.clear();

			inst.board    = (Blackboard) ois.readObject();
			inst.canvas   = (MainCanvas) ois.readObject();

			inst.board.build(p);
			inst.canvas.build(p, inst.cp5);

			ois.close();

		} catch (Exception e) {
			p.println("ERROR loading file: " + file + " [exception: " + e.toString() + "].");
			inst.board  = new Blackboard(inst);
			inst.canvas = new MainCanvas(inst, inst.cp5);

		}

		inst.canvas.root.show();
		inst.cp5.setAutoDraw(true);
		inst.is_loading = false;

		p.println("done loading!");
	}

}
