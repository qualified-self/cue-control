/************************************************
** Class representing the blackboard ***********
************************************************
** jeraman.info, Oct. 11 2016 ******************
************************************************
** UPDATE: part of this code (support to expressions,
** and the ConcurrentHashMap)was written by Sofian
** and incorporated by him into the original code.
************************************************/

import java.util.concurrent.ConcurrentHashMap;
import java.io.Serializable;
import processing.core.PApplet;
import java.util.regex.*;
import java.util.*;
import java.util.Collection;
import java.math.BigDecimal;
import java.text.NumberFormat;
import oscP5.*;


/// Blackboard class.
public class Blackboard extends ConcurrentHashMap<String, Object> implements Serializable {
  int mywidth = 60;
  int myheight = 20;
  int x;
  int y;
  boolean debug = false;

  transient private PApplet p;

  //contructor
  public Blackboard (PApplet p) {
    //this.x = width-(mywidth*3)-20;
    //this.x = width-(mywidth*3)-20;
    //this.y = 20;
    this.build(p);
    init_global_variables();
  }

  void set_debug (boolean b) {
    this.debug = b;
  }

  void build(PApplet p) {
    System.out.println("@TODO [BLACKBOARD] verify what sorts of things needs to be initialize when loaded from file");
    this.p = p;
    init_global_variables();
    set_gui_position(p.width-(mywidth*3)-2, 20);
  }

  void init_global_variables() {
      put("mouseX", (float)p.mouseX/p.width);
      put("mouseY", (float)p.mouseY/p.height);
      put("mousePressed", p.mousePressed);
      put("key", p.key);
      put("keyPressed", p.keyPressed);
      //put("keyCode", p.keyCode);
      //put("stateTimer", 0);
  }

  void update_global_variables() {
    //if the blackboard wasn't loaded yet
    if (p==null) return;

    replace("mouseX", (float)p.mouseX/p.width);
    replace("mouseY", (float)p.mouseY/p.height);
    replace("mousePressed", p.mousePressed);
    replace("key", p.key);
    replace("keyCode", p.keyCode);
    replace("keyPressed", p.keyPressed);
  }

  void reset() {
    this.clear();
    this.init_global_variables();
  }

  /**
  * Replaces variable names in expression with pattern "$varName" or "${varName}"
  * with values corresponding to these variables from the blackboard.
  */
  String processExpression(String expr) {

    //does not support strings
    Pattern pattern1 = Pattern.compile("(\\$(\\w+))");
  	Pattern pattern2 = Pattern.compile("(\\$\\{(\\w+)\\})"); //" <-- this comment to avoid code-highlight issues in Atom

    //does not suppor 3 bb variables
    //Pattern pattern1 = Pattern.compile("([^\\\\]\\$(\\w+))");
    //Pattern pattern2 = Pattern.compile("([^\\\\]\\$\\{(\\w+)\\})"); //" <-- this comment to avoid code-highlight issues in Atom

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
        if (debug)
          System.out.println("Blackboard variable not found: " + varName);
    }
    if (debug)
      System.out.println("final expression: " + expr);

    return expr;
    //		return expr.replaceAll("\\\\\\$", "$");
  }

  /////////////////
  // gui methods
  void set_gui_position (int newx, int newy) {
    this.x = newx;
    this.y = newy;
  }

  //draws both the header and the items
  void draw() {
    //if the blackboard wasn't loaded yet
    if (p==null) return;
    draw_header_gui();
    draw_bb_items();
  }

  //draws the header
  void draw_header_gui () {


    p.noStroke();
    p.fill(255, 200);
    p.rectMode(p.CENTER);
    p.rect(x+mywidth, y, (mywidth*3), myheight);
    p.rectMode(p.CORNERS);

    p.fill(50);
    p.textAlign(p.CENTER, p.CENTER);
    p.text("BLACKBOARD", x+mywidth, y);
  }

  //draws the items
  void draw_bb_items () {
    draw_header_gui();
    int i=0;

    List<String> ordered = new ArrayList<String>(this.keySet());
    Collections.sort(ordered);

    for(String val : ordered) {
        drawItem(val, this.get(val), x, y+(myheight*(i+1))+i+1, mywidth, myheight);
        i++;
    }

    /*
    for (ConcurrentHashMap.Entry<String, Object> element : entrySet()) {
      if (!blacklisted(element)) {
        drawItem(element, x, y+(myheight*(i+1))+i+1, mywidth, myheight);
        i++;
      }
    }
    */
  }

  //list of memory items that should not be displyed to the use
  boolean blacklisted(ConcurrentHashMap.Entry<String, Object> element) {
    String varname = element.getKey().toString();
    if ((varname.contains("frequency") && varname.length() > 25)||
        (varname.contains("amplitude") && varname.length() > 25))
        //add a new item here
        return false;//true;
    else return false;
  }


  //void drawItem(ConcurrentHashMap.Entry<String, Object> element, int posx, int posy, int mywidth, int myheight) {
  void drawItem(String var_name, Object var_value, int posx, int posy, int mywidth, int myheight) {
    int xoffset = mywidth+1;
    //if the blackboard wasn't loaded yet

    //header
    p.noStroke();
    p.fill(255, 50);
    p.rectMode(p.CENTER);
    p.rect(posx, posy, mywidth, myheight);
    p.rect(posx+xoffset, posy, mywidth, myheight);
    p.rect(posx+xoffset+xoffset, posy, mywidth, myheight);

    p.fill(200);
    p.textAlign(p.CENTER, p.CENTER);

    String type_name = var_value.getClass().getName();
    //Object value     = element.getValue();
    String value_string = var_value.toString();

    //in case it's a float, only exhibits two decimal points.
    if (var_value instanceof Float) value_string = round((float)var_value, 2).toString();
    if (var_value instanceof Double) value_string = round((float)((double)var_value), 2).toString();

    p.text(type_name.replace("java.lang.", ""), posx, posy);
    p.text(var_name,   posx+xoffset, posy);
    p.text(value_string, posx+xoffset+xoffset+5, posy);
  }


  //adding input osc support to the blackboard
  void oscEvent(OscMessage msg) {
    if (debug) {
      System.out.print("### received an osc message.");
      System.out.print(" addrpattern: "+msg.addrPattern());
      System.out.print(" typetag: "+msg.typetag());
    }

    //gets the name
    String name = msg.addrPattern();
    //processing the address
    name = name.substring(1, name.length());
    name = name.replace("/", "_");

    String typetag = msg.typetag();
    int typetag_size = typetag.length();

    p.println(msg.typetag());

    for (int i = 0; i < typetag_size; i++) {

      //value will be stored in this variable
      Object value = null;

      //checks for the right data type

      //     if (typetag.charAt(i).equals("i")) //integer
      if (typetag.charAt(i)=='i')//integer
        value = msg.get(i).intValue();
      //else if (msg.checkTypetag("f")) //float
      if (typetag.charAt(i)=='f')//float
        value = msg.get(i).floatValue();
      //else if (msg.checkTypetag("d")) //double
      if (typetag.charAt(i)=='d')//double
        value = msg.get(i).doubleValue();
      //else if (msg.checkTypetag("s")) //string
      if (typetag.charAt(i)=='s')//string
        value = msg.get(i).stringValue();
      //else if (msg.checkTypetag("b")) //boolean
      if (typetag.charAt(i)=='b')//boolean
        value = msg.get(i).booleanValue();
      //else if (msg.checkTypetag("l")) //long
      if (typetag.charAt(i)=='l')//long
        value = msg.get(i).longValue();
      //else if (msg.checkTypetag("c")) //char
      if (typetag.charAt(i)=='c')//char
        value = msg.get(i).charValue();

      if (!containsKey(name+"_"+i)) put(name+"_"+i, value);
      else                    replace(name+"_"+i, value);
    }
  }


  public BigDecimal round(float d, int decimalPlace) {
      BigDecimal bd = new BigDecimal(Float.toString(d));
      bd = bd.setScale(decimalPlace, BigDecimal.ROUND_HALF_UP);
      return bd;
  }

}
