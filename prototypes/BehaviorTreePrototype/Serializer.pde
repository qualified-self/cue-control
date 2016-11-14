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
      oos.writeObject(root);
      oos.close();
    } catch (Exception e) {
      println("ERROR saving to file: " + file + " [exception: " + e.toString() + "].");
    }
  }

  public void _load(File file) {
    try {
      ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));

      board = (Blackboard) ois.readObject();
      root  = (BaseNode)   ois.readObject();
      ois.close();
    } catch (Exception e) {
      println("ERROR saving to file: " + file + " [exception: " + e.toString() + "].");
    }
  }

}
