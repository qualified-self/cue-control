

/******************************************************************************
 ******************************************************************************
 ** PIE MENU ******************************************************************
 ** First skeleton based on: *************************************************
 ** https://forum.processing.org/one/topic/pie-menu-in-processing.html ********
 ******************************************************************************
 *** jeraman.info, Nov. 23 2016 ***********************************************
 *****************************************************************************/

import processing.core.PApplet;

class PieMenu {


  //this is the variable that stores all the possible tasks
  //String[] task_list = {"State Machine","", "", "Set Blackboard", "Audio", "OSC"};

  String[] options;
  private float  diam, textdiam, innerCircleDiam;
  private int    selected;
  private int    background_color;
  private int    font_color;
  private int    active_color;
  private int      x;
  private int      y;
  private boolean  is_showing;
  private boolean  up;
  private boolean  down;
  private float    size;
  private float    startTime;
  private float    maxTime;
  private PApplet  p;

  //basic constructor
  public PieMenu (PApplet p) {
    this.p = p;
    //this.options          = task_list;

    this.background_color = p.color(25, 25, 25);
    this.active_color     = p.color(100);
    this.font_color       = p.color(255);
    //this.background_color = color(25, 25, 25);
    //this.active_color     = color(100);
    //this.font_color       = color(255);
    this.x                = (int)p.width/2;
    this.y                = (int)p.height/2;
    this.set_diam(200);

    this.is_showing       = false;
    this.up               = false;
    this.down             = false;
    this.size             = 0;
    this.startTime        = p.millis();
    this.maxTime          = 0.4f;
    this.selected		  = -1;
  }

  //another constructor
  public PieMenu (PApplet p, int x, int y, int diam) {
    this(p);
    this.x = x;
    this.y = y;
    this.set_diam(diam);
    //this.innerCircleDiam = innerCircleDiam;
    //this.innerCircleDiam = diam;
  }

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }

  float getDiam() {
    return diam;
  }

  //i created this setup because of a misterious bug with the millis function
  //the first time i try to open the pie menu, it freezes for a while before proceeding
  //ideadlly, i wouldn't need this setup
  void setup() {
    show();
    hide();
  }

  void set_options (String[] options) {
    this.options = options;
  }

  //shows this pie menu
  void show() {
    is_showing = true;
    startTime  = p.millis();
    size = 0;
    up = true;
    down = false;
  }

  //hides this pie menu
  void hide() {
    startTime  = p.millis();
    size = 1;
    down = true;
    up = false;
    selected = -1;
  }

  void direct_hide() {
    is_showing = false;
    size = 0;
    down = false;
    up = false;
    selected = -1;
  }

  void update_timer() {

    if (up) {
      //udpating the size
      size =((float)p.millis() - startTime)/(maxTime*1000);
      //if finished
      if (size > 1)
        up = false;
    }

    if (down) {
      //udpating the size
      size =((float)p.millis() - startTime)/(maxTime*1000);
      size = maxTime-size;

      //if finished
      if (size < 0) {
        down = false;
        is_showing = false;
      }
    }
  }

  //sets the diam and the textdiam
  void set_diam (int newdiam) {
    this.diam           = newdiam;
    this.textdiam       = this.diam/2.5f;
    this.innerCircleDiam= this.diam/4f;
  }

  //sets the diam of the inner circle
  void set_inner_circle_diam (float newdiam) {
    this.innerCircleDiam = newdiam;
  }

  //sets the x/y position of this pie menu
  void set_position (int x, int y) {
    this.x = x;
    this.y = y;
  }

  void draw () {
    p.pushMatrix();
    p.translate(this.x, this.y);
    update_timer();
    p.scale(size);
    draw_menu();
    p.popMatrix();
  }

  //draws the pie menu
  void draw_menu() {
    //if it' not showing, return!
    if (!is_showing()) return;

    //fill(0, 0, 0);
    //ellipse(0, 0, diam+5, diam+5);

    p.fill(0, 0, 0, 150);
    p.ellipse(0, 0, diam+3, diam+3);

    p.noStroke();
    //p.fill(125);
    //p.fill(255);

    float mouseTheta = p.atan2(p.mouseY-this.y, p.mouseX-this.x);
    float piTheta    = mouseTheta>=0?mouseTheta:mouseTheta+p.TWO_PI;
    float op         = options.length/p.TWO_PI;

    this.selected = -1;

    for (int i=0; i<options.length; i++) {
      //compute the proper angles
      float s = i/op-(p.PI/this.options.length);
      float e = (i+0.98f)/op-(p.PI/this.options.length);

      //if it's a empty option, make it black
      if (this.options[i].equals(""))
        p.fill(0, 0, 0, 1);
      //otherwise, make it interactive as part of the pie menu
      else {
        //float s = i/op-PI*0.125;
        //float e = (i+0.98)/op-PI*0.125;
        if (piTheta>= s && piTheta <= e && is_a_point_inside_the_menu(p.mouseX, p.mouseY) && (!is_a_point_inside_the_core_circle(p.mouseX, p.mouseY))) {
          p.fill(active_color);
          selected = i;
        } else
          p.fill(background_color);
      }
      //arc(this.x, this.y, diam, diam, s, e);
      p.arc(0, 0, diam, diam, s, e);
      //should fill the same color as the background
      //fill(0);
      //ellipse(0, 0, innerCircleDiam, innerCircleDiam);
    }

    p.fill(font_color);
    p.textAlign(p.CENTER, p.CENTER);

    for (int i=0; i<options.length; i++) {
      float m = i/op;
      p.text(options[i], p.cos(m)*textdiam, p.sin(m)*textdiam);
      //text(options[i], this.x+cos(m)*textdiam, this.y+sin(m)*textdiam);
    }
  }

  boolean is_a_point_inside_the_menu(int tx, int ty) {
    float r = diam/2;
    return (Math.pow(tx-x, 2)+Math.pow(ty-y, 2)<Math.pow(r, 2));
  }

  boolean is_a_point_inside_the_core_circle(int tx, int ty) {
    //replace that by the radius of the state
    float r = innerCircleDiam/2;
    return (Math.pow(tx-x, 2)+Math.pow(ty-y, 2)<Math.pow(r, 2));
  }

  int get_selection() {
    return selected;
  }

  boolean is_showing() {
    return is_showing;
  }

  boolean is_fading_away() {
    return down;
  }
  
  boolean is_hidden_or_fading () {
	  return !is_showing() || is_fading_away();
  }
}
