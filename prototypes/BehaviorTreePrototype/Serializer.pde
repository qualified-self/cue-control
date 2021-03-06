public class Serializer {

  Serializer() {}

  File lastSaveFile = null;

  void save() {
    if (lastSaveFile == null)
      saveAs();
    else
      saveAs(lastSaveFile);
  }

  void saveAs() {
    selectOutput("Select file: ", "saveAs", lastSaveFile, this);
  }

  void load() {
    selectInput("Select file: ", "load", lastSaveFile, this);
  }

  public void saveAs(File file) {
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

  public void load(File file) {
    println("Trying to load file: " + file);
    try {
      ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));

      board = (Blackboard) ois.readObject();
      root  = (CompositeNode)   ois.readObject();

      board.build();
      root.build();

      ois.close();
    } catch (Exception e) {
      println("ERROR reading from file: " + file + " [exception: " + e.toString() + "].");
    }
  }

}
