/******************************************************
** Class that implements file saving/loading *********
******************************************************
** this code was written by Sofian and incorporated *
** into my prototype in DEc. 1st *********************
*****************************************************/

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
      //oos.writeObject(canvas);
      oos.close();
    } catch (Exception e) {
      println("ERROR saving to file: " + file + " [exception: " + e.toString() + "].");
      e.printStackTrace();
    }
  }

  public void _load(File file) {
    try {
      ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));

      board    = (Blackboard) ois.readObject();
      //canvas     = (Canvas)   ois.readObject();

      board.build();
      //canvas.build();

      ois.close();
    } catch (Exception e) {
      println("ERROR saving to file: " + file + " [exception: " + e.toString() + "].");
    }
  }

}
