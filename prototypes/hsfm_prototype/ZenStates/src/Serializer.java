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

	Serializer(ZenStates p) {
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
			oos.writeObject(p.board());
			oos.writeObject(p.canvas());
			oos.close();
		} catch (Exception e) {
			p.println("ERROR saving to file: " + file + " [exception: " + e.toString() + "].");
			e.printStackTrace();
		}
	}

	public void _load(File file) {
		
		try {	
			p.is_loading = true;
			p.canvas.root.hide();
			p.cp5.setAutoDraw(false);

			ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));
			p.board.clear();
			p.canvas.clear();

			p.board    = (Blackboard) ois.readObject();
			p.canvas   = (MainCanvas) ois.readObject();

			p.board.build(p);
			p.canvas.build(p, p.cp5);

			ois.close();

		} catch (Exception e) {
			p.println("ERROR loading file: " + file + " [exception: " + e.toString() + "].");
			p.board  = new Blackboard(p);
			p.canvas = new MainCanvas(p, p.cp5);

		}

		p.canvas.root.show();
		p.cp5.setAutoDraw(true);
		p.is_loading = false;

		p.println("done loading!");
	}

}
