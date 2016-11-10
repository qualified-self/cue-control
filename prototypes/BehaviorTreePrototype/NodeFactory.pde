import java.lang.reflect.*;

/// Allows the dynamic creation of nodes.
class NodeFactory {

  PApplet app;

  NodeFactory(PApplet app) {
    this.app = app;
  }

  /// Creates a new node based on description string. Returns null if error.
  BaseNode createNode(String str) {
    // Split list in tokens.
    // Source: http://stackoverflow.com/questions/7804335/split-string-on-spaces-in-java-except-if-between-quotes-i-e-treat-hello-wor
    List<String> list = new ArrayList<String>();
    Matcher m = Pattern.compile("([^\"]\\S*|\".+?\")\\s*").matcher(str);
    while (m.find())
      list.add(m.group(1).replace("\"", "")); // Add .replace("\"", "") to remove surrounding quotes.

    // Wrong statement.
    if (list.isEmpty()) {
      app.println("Invalid empty string.");
      return null;
    }

    String classType = list.get(0);

    int nArguments = list.size()-1;
    String[] arguments = new String[nArguments];
    for (int i=0; i<nArguments; i++) {
      arguments[i] = list.get(i+1);
    }

    return createNode(classType, arguments);
  }

  /// Creates node based on class name and a set of arguments to the constructor, expressed as string.
  BaseNode createNode(String classType, String[] arguments)
  {
    // Convert constructor arguments to objects.
    int nArguments = arguments.length;
    Object[] argumentObjects = new Object[nArguments+1];
    Class[] argumentClasses  = new Class[nArguments+1];
    argumentObjects[0] = app;
    argumentClasses[0] = app.getClass();
    for (int i=0; i<nArguments; i++) {
      try {
        Expression expr = new Expression(arguments[i]);
        Object obj = expr.eval();
        argumentObjects[i+1] = obj;
        argumentClasses[i+1] = obj.getClass();
      } catch (ScriptException e) {
        argumentObjects[i+1] = arguments[i];
        argumentClasses[i+1] = String.class;
      }
    }

    // Try to generate new instance.
    try {
      // Gather all constructors.
      classType = app.getClass().getName() + "$" + classType;
      Class<?> nodeClass = Class.forName(classType);
      Constructor<?>[] constructors = nodeClass.getConstructors();
      for (Constructor<?> c : constructors)
      {
        // Try each constructor with arguments.
        try {
          return (BaseNode) c.newInstance(argumentObjects);
        }
        catch (IllegalArgumentException e) {}
      }
      app.println("No valid constructor found for arguments.");
      app.println("Classtype = " + classType);
      app.println("Arguments = " + argumentObjects);

      return null;
      // Call constructor.
    } catch (Exception e) {
        app.println("ERROR: error creating node of class " + classType + ".");
        app.println(e);
        return null;
    }
  }

}