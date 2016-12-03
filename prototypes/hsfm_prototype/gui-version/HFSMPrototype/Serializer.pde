/******************************************************
** Class that implements file saving/loading *********
******************************************************
** this code was written by Sofian and incorporated *
** into my prototype in DEc. 1st *********************
*****************************************************/

boolean is_loading = false;

public class Serializer {

  Serializer() {}

  File lastSaveFile = null;

  void save() {
    if (lastSaveFile == null)
      saveAs();
    else
      _saveAs(lastSaveFile);
  }

  void saveAs() {
    selectOutput("Select file: ", "_saveAs", lastSaveFile, this);
  }

  void load() {
    selectInput("Select file: ", "_load", lastSaveFile, this);
  }

  public void _saveAs(File file) {
    if (file == null)
      return;
    try {
      ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file));
      oos.writeObject(board);
      oos.writeObject(canvas);
      oos.close();
    } catch (Exception e) {
      println("ERROR saving to file: " + file + " [exception: " + e.toString() + "].");
      e.printStackTrace();
    }
  }

  public void _load(File file) {
    try {
      is_loading = true;
      ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));

      canvas.root.hide();
      cp5.setAutoDraw(false);
      board.clear();
      canvas.clear();

      board    = (Blackboard) ois.readObject();
      canvas   = (MainCanvas) ois.readObject();

      PApplet p = HFSMPrototype.instance();

      board.build(p);
      canvas.build(p, cp5);

      ois.close();

      is_loading = false;
      canvas.root.show();
      cp5.setAutoDraw(true);

      println("done loading!");

    } catch (Exception e) {
      println("ERROR loading file: " + file + " [exception: " + e.toString() + "].");
    }
  }

}
