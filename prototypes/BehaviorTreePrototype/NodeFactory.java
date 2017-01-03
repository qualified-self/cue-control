import java.lang.reflect.*;
import javax.script.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/// Allows the dynamic creation of nodes.
class NodeFactory {

  ArrayList<String> nodeTypes;
  ArrayList<String> decoratorTypes;

  NodeFactory() {
    nodeTypes = new ArrayList<String>();
    decoratorTypes = new ArrayList<String>();

    registerNode("blackboard-ramp");
    registerNode("blackboard-set");
    registerNode("constant");
    registerNode("delay");
    registerNode("osc-receive");
    registerNode("osc-send");
    registerNode("parallel");
    registerNode("selector");
    registerNode("sequence");
    registerNode("simple-parallel");
    registerNode("sound");
    registerNode("text");

    registerDecorator("chrono");
    registerDecorator("constant");
    registerDecorator("guard");
    registerDecorator("randomize");
    registerDecorator("while");
  }

  void registerNode(String nodeType) {
    nodeTypes.add(nodeType);
  }

  void registerDecorator(String decoratorType) {
    decoratorTypes.add(decoratorType);
  }

  ArrayList<String> nodesStartingWith(String str, boolean isDecorator) {
    return _stringsStartingWith(str, isDecorator ? decoratorTypes : nodeTypes);
  }

  ArrayList<String> _stringsStartingWith(String str, ArrayList<String> array) {
    ArrayList<String> result = new ArrayList<String>(array.size());
    for (String s : array)
      if (s.startsWith(str))
        result.add(s);
    return result;
  }


  BaseNode createNode(String str) {
    return createNode(str, false);
  }

  /// Creates a new node based on description string. Returns null if error.
  BaseNode createNode(String str, boolean isDecorator) {
    // Split list in tokens.
    // Source: http://stackoverflow.com/questions/7804335/split-string-on-spaces-in-java-except-if-between-quotes-i-e-treat-hello-wor
    List<String> list = new ArrayList<String>();
    Matcher m = Pattern.compile("([^\"]\\S*|\".+?\")\\s*").matcher(str);
    while (m.find())
      list.add(m.group(1).replace("\"", "")); // Add .replace("\"", "") to remove surrounding quotes.

    // Wrong statement.
    if (list.isEmpty()) {
      Console.instance().log("Invalid empty string.");
      return null;
    }

    // Find classtype.
    String classType = nodeNameToClassName(list.get(0), isDecorator);

    int nArguments = list.size()-1;
    String[] arguments = new String[nArguments];
    for (int i=0; i<nArguments; i++) {
      arguments[i] = list.get(i+1);
    }

    return createNode(classType, arguments, isDecorator);
  }

  /// Creates node based on class name and a set of arguments to the constructor, expressed as string.
  BaseNode createNode(String classType, String[] arguments, boolean isDecorator)
  {
    // First verify if classType is eligible.
    String nodeName = classNameToNodeName(classType);
    if (! (isDecorator ? decoratorTypes.contains(nodeName) : nodeTypes.contains(nodeName)))
    {
      Console.instance().log("Unsupported class type: " + nodeName + ".");
      return null;
    }

    // Convert constructor arguments to objects.
    int nArguments = arguments.length;
    Object[] argumentObjects = new Object[nArguments];
    Class[] argumentClasses  = new Class[nArguments];
    // argumentObjects[0] = this;
    // argumentClasses[0] = this.getClass();
    for (int i=0; i<nArguments; i++) {
      try {
        Expression expr = new Expression(arguments[i]);
        Object obj = expr.eval();
        argumentObjects[i] = obj;
        argumentClasses[i] = obj.getClass();

      } catch (ScriptException e) {
        argumentObjects[i] = arguments[i];
        argumentClasses[i] = String.class;
      }
//      Console.instance().log("Argument[" + i + "] has type :" + argumentClasses[i].getName());
    }

    // Try to generate new instance.
    try {
      // Gather all constructors.
      //classType = app.getClass().getName() + "$" + classType;
      Class<?> nodeClass = Class.forName(classType);
      Constructor<?>[] constructors = nodeClass.getConstructors();
      for (Constructor<?> c : constructors)
      {
        // Try each constructor with arguments.
        try {
          return (BaseNode) c.newInstance(argumentObjects);
        }
        catch (IllegalArgumentException e) {
          System.out.println("Bad argument: " + e);
        }
        catch (Exception e) {
          System.out.println("Exception: " + e);
        }
      }
      Console.instance().log("No valid constructor found for arguments. Available declarations:");
      // Console.instance().log("Classtype = " + classType);
      // Console.instance().log("Arguments = " + argumentObjects);

      for (Constructor<?> c : constructors)
      {
        String description = classNameToNodeName(c.getName());
        Class[] paramTypes = c.getParameterTypes();
        for (Class type : paramTypes)
          description += " " + Utils.camelCaseToDash(type.getSimpleName());
        Console.instance().log(" - " + description);
      }

      return null;
      // Call constructor.
    } catch (Exception e) {
        Console.instance().log("ERROR: error creating node of class " + classType + ".");
        Console.instance().log(e);
        // app.println("ERROR: error creating node of class " + classType + ".");
        // app.println(e);
        return null;
    }
  }

  static String nodeNameToClassName(String name, boolean isDecorator) {
    return Utils.dashToCamelCase(name) + (isDecorator ? "Decorator" : "Node");
  }

  static String classNameToNodeName(String className) {
    int suffixLength = (className.endsWith("Node") ? "Node" : "Decorator").length();
    return Utils.camelCaseToDash(className.substring(0, className.length() - suffixLength));
  }
}
