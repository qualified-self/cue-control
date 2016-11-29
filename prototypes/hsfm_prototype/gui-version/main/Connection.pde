/************************************************
 ** Class representing a conection between two states in the HFSM
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

public class Connection {
  private State      next_state;
  private Expression expression;
  private int        priority;

  //constructor for an empty transition
  public Connection (State ns, int priority) {
    this.next_state = ns;
    this.expression = new Expression("true");
    this.priority   = priority;
  }

  //constructor for a more complex transition
  public Connection (State ns, Expression expression, int priority) {
    this(ns, priority);
    this.expression = expression;
  }

  //function that tries to evaluates the value (if necessary) and returns the real value
  boolean is_condition_satisfied () {
    Object ret = false;

    try {
      ret = expression.eval(bb);
    }
    catch (ScriptException e) {
      println("Problems in processing certain transition condition. Expr: " + expression.toString() + " next state: " + next_state.toString());
      ret = false;
    }

    if (ret instanceof Boolean)
      return (boolean)ret;
    else {
      println("Expr: " + expression.toString() + " result is not a boolean. it is a " + ret.toString());
      return false;
    }
  }

  //updates an expression
  void update_expression() {
    this.expression = expression;
  }

  //returns the next state
  State get_next_state() {
    return next_state;
  }

  //gets a condition
  Expression get_expression() {
    return this.expression;
  }


  /*******************************************
   ** GUI FUNCTIONS ***************************
   ********************************************/

   Group return label () {
     
   }
}
