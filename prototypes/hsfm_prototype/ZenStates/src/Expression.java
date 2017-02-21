
/************************************************
 ** Class used to interpret expressions developed by Sofian
 ************************************************/


 import javax.script.*;
 import java.io.Serializable;
 import processing.core.PApplet;

/// Expression class which allows to compute javascript-style expressions with variables from the blackboard.
class Expression implements Serializable {

  // Static components.
  static transient ScriptEngineManager manager;
  static transient ScriptEngine engine;

  String expression;

  public Expression(String expression) {
    this.expression = expression;
    PApplet p = ZenStates.instance();
    this.build(p);
  }

  void build(PApplet p) {

    if (this.manager == null || this.engine == null) {
      this.manager = new ScriptEngineManager();
      this.engine = manager.getEngineByName("js");

      System.out.println("building an expression " + toString());
      System.out.println("engine is " + engine.toString() + "manager is" + manager.toString());
      try {
        // Load library for math operations.
        java.util.Scanner s = new java.util.Scanner(new java.net.URL("file://" + p.dataPath("math.js")).openStream()).useDelimiter("\\A");
        engine.eval(s.hasNext() ? s.next() : "");
      }
      catch (Exception e) {
        System.out.println(e);
      }
    }
  }

  /// Computes expression using blackboard and returns result.
	Object eval(Blackboard agent) throws ScriptException {
    //System.out.println("eval an expression " + toString());
    //@TODO DEBUGGING INFO
    if (agent==null) System.out.println("agent " + agent);
    if (expression==null) System.out.println("expression " + expression);
    if (engine==null) System.out.println("engine " + engine);
    return engine.eval(agent.processExpression(expression));
	}

  public String toString() {
    return expression;
  }

}
