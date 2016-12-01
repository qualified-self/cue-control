/************************************************
** Class representing the blackboard ***********
************************************************
** jeraman.info, Oct. 11 2016 ******************
************************************************
** UPDATE: part of this code (support to expressions,
** and the ConcurrentHashMap)was written by Sofian
** and incorporated by him into the original code.
************************************************/

/// Blackboard class.
class Blackboard extends ConcurrentHashMap<String, Object>
{

  //does not support strings
  Pattern pattern1 = Pattern.compile("(\\$(\\w+))");
	Pattern pattern2 = Pattern.compile("(\\$\\{(\\w+)\\})"); //" <-- this comment to avoid code-highlight issues in Atom


  //does not suppor 3 bb variables
  //Pattern pattern1 = Pattern.compile("([^\\\\]\\$(\\w+))");
  //Pattern pattern2 = Pattern.compile("([^\\\\]\\$\\{(\\w+)\\})"); //" <-- this comment to avoid code-highlight issues in Atom

  int mywidth = 60;
  int myheight = 20;
  int x;
  int y;

  //float stateTimerMilestone = 0;

  //contructor
  public Blackboard () {
    //this.x = width-(mywidth*3)-20;
    //this.x = width-(mywidth*3)-20;
    //this.y = 20;

    init_global_variables();
  }

  void build() {
    println("@TODO [BLACKBOARD] verify what sorts of things needs to be initialize when loaded from file");
  }

  void init_global_variables() {
      put("mouseX", mouseX);
      put("mouseY", mouseY);
      put("mousePressed", mousePressed);
      put("key", key);
      put("keyCode", keyCode);
      put("keyPressed", keyPressed);
      //put("stateTimer", 0);
  }

  void update_global_variables() {
      replace("mouseX", mouseX);
      replace("mouseY", mouseY);
      replace("mousePressed", mousePressed);
      replace("key", key);
      replace("keyCode", keyCode);
      replace("keyPressed", keyPressed);

      /*
      //in case the main state is running
      if (t.get_status()==Status.RUNNING)
        //updates the timer
        update_state_timer();
      else
        reset_state_timer();
      */
  }

  /*
  void update_state_timer() {
      replace("stateTimer", ((float)millis()/1000)-stateTimerMilestone);
  }

  void reset_state_timer() {
      this.stateTimerMilestone = (float)millis()/1000;
      replace("stateTimer", 0);
  }
  */

  /**
  * Replaces variable names in expression with pattern "$varName" or "${varName}"
  * with values corresponding to these variables from the blackboard.
  */
  String processExpression(String expr) {
    expr = _processPattern(pattern1, expr);
    //println("Converted expression1: " +expr);
    expr = _processPattern(pattern2, expr);
    //println("Converted expression2: " +expr);
    return expr;
  }

  String _processPattern(Pattern pattern, String expr) {
    Matcher matcher = pattern.matcher(expr);
    while (matcher.find())
    {
      String varName = matcher.group(2); // candidate var name in blackboard
      if (containsKey(varName))
      {
        String value = get(varName).toString();
        expr = matcher.replaceFirst(value);
        matcher = pattern.matcher(expr);
      }
      else
        if (debug)  println("Blackboard variable not found: " + varName);
    }
    if (debug)
      println("final expression: " + expr);

    return expr;
    //		return expr.replaceAll("\\\\\\$", "$");
  }


  /*
  String _processPattern(Pattern pattern, String expr) {
    Matcher matcher = pattern.matcher(expr);
    while (matcher.find())		{
      String varName = matcher.group(2); // candidate var name in blackboard
      if (containsKey(varName))
      {
        String value = get(varName).toString();
        expr = matcher.replaceFirst(value);
        matcher = pattern.matcher(expr);
      }

      else
        println("Blackboard variable not found: " + varName);
    }
    println("Final expression: " + expr);
    return expr;
    //		return expr.replaceAll("\\\\\\$", "$");
  }
  */

  /////////////////
  // gui methods
  void set_gui_position (int newx, int newy) {
    this.x = newx;
    this.y = newy;
  }

  //draws both the header and the items
  void draw() {
    draw_header_gui ();
    draw_bb_items ();
  }

  //draws the header
  void draw_header_gui () {
    noStroke();
    fill(255, 200);
    rectMode(CENTER);
    rect(x+mywidth, y, (mywidth*3), myheight);
    rectMode(CORNERS);

    fill(50);
    textAlign(CENTER, CENTER);
    text("BLACKBOARD", x+mywidth, y);
  }

  //draws the items
  void draw_bb_items () {
    draw_header_gui();
    int i=0;
    for (Map.Entry<String, Object> element : entrySet()) {
      drawItem(element, x, y+(myheight*(i+1))+i+1, mywidth, myheight);
      i++;
    }
  }


  void drawItem(Map.Entry<String, Object> element, int posx, int posy, int mywidth, int myheight) {
    int xoffset = mywidth+1;

    //header
    noStroke();
    fill(255, 50);
    rectMode(CENTER);
    rect(posx, posy, mywidth, myheight);
    rect(posx+xoffset, posy, mywidth, myheight);
    rect(posx+xoffset+xoffset, posy, mywidth, myheight);

    fill(200);
    textAlign(CENTER, CENTER);
    String type_name = element.getValue().getClass().getName();
    Object value     = element.getValue();
    String value_string = value.toString();;

    //in case it's a float, only exhibits two decimal points.
    if (value instanceof Float) value_string = round((float)value, 2).toString();
    if (value instanceof Double) value_string = round((float)((double)value), 2).toString();

    text(type_name.replace("java.lang.", ""), posx, posy);
    text(element.getKey().toString(),   posx+xoffset, posy);
    text(value_string, posx+xoffset+xoffset+5, posy);
  }


  //adding input osc support to the blackboard
  void oscEvent(OscMessage msg) {
    print("### received an osc message.");
    print(" addrpattern: "+msg.addrPattern());
    print(" typetag: "+msg.typetag());

    //gets the name
    String name = msg.addrPattern();
    //processing the address
    name = name.substring(1, name.length());
    name = name.replace("/", "_");

    //value will be stored in this variable
    Object value = null;

    //checks for the right data type
         if (msg.checkTypetag("i")) //integer
      value = msg.get(0).intValue();
    else if (msg.checkTypetag("f")) //float
      value = msg.get(0).floatValue();
    else if (msg.checkTypetag("d")) //double
      value = msg.get(0).doubleValue();
    else if (msg.checkTypetag("s")) //string
      value = msg.get(0).stringValue();
    else if (msg.checkTypetag("b")) //boolean
      value = msg.get(0).booleanValue();
    else if (msg.checkTypetag("l")) //long
      value = msg.get(0).longValue();
    else if (msg.checkTypetag("c")) //char
      value = msg.get(0).charValue();

    if (!containsKey(name)) put(name, value);
    else                    replace(name, value);
  }

}
