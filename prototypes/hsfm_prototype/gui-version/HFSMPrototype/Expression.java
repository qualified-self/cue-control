
/************************************************
 ** Class used to interpret expressions developed by Sofian
 ************************************************/


 import javax.script.*;
 import java.io.Serializable;
 import processing.core.PApplet;

/// Expression class which allows to compute javascript-style expressions with variables from the blackboard.
class Expression implements Serializable {

  // Static components.
  transient ScriptEngineManager manager;
  transient ScriptEngine engine;

  String expression;

  public Expression(String expression) {
    this.expression = expression;
    PApplet p = HFSMPrototype.instance();
    this.build(p);
  }

  void build(PApplet p) {

    if (manager == null) {
      manager = new ScriptEngineManager();
      engine = manager.getEngineByName("js");
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
    return engine.eval(agent.processExpression(expression));
	}

  public String toString() {
    return expression;
  }

}
