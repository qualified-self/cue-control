/******************************************************************************
 ******************************************************************************
 ** PIE MENU ******************************************************************
 ** First skeleton based on: *************************************************
 ** https://forum.processing.org/one/topic/pie-menu-in-processing.html ********
 ******************************************************************************
 *** jeraman.info, Nov. 23 2016 ***********************************************
 *****************************************************************************/

//this is the variable that stores all the possible tasks
String[] task_list = {"State Machine","", "", "Set Blackboard", "Audio", "OSC"};


class PieMenu {

  String[] options;
  private float    diam, textdiam, innerCircleDiam;
  private int      selected;
  private color    background_color;
  private color    font_color;
  private color    active_color;
  private int      x;
  private int      y;
  private boolean  is_showing;
  private boolean  up;
  private boolean  down;
  private float    size;
  private float    startTime;
  private float    maxTime;

  //basic constructor
  public PieMenu () {
    this.options          = task_list;
    this.background_color = color(50, 50, 50, 100);
    this.active_color     = color(100);
    this.font_color       = color(255);
    this.x                = (int)width/2;
    this.y                = (int)height/2;
    this.set_diam(200);

    this.is_showing       = false;
    this.up               = false;
    this.down             = false;
    this.size             = 0;
    this.startTime        = millis();
    this.maxTime          = 0.4;
  }

  //another constructor
  public PieMenu (int x, int y, int innerCircleDiam) {
    this();
    this.x = x;
    this.y = y;
    this.innerCircleDiam = innerCircleDiam;
  }


  //i created this setup because of a misterious bug with the millis function
  //the first time i try to open the pie menu, it freezes for a while before proceeding
  //ideadlly, i wouldn't need this setup
  void setup() {
    show();
    hide();
  }

  //shows this pie menu
  void show() {
    is_showing = true;
    startTime  = millis();
    size = 0;
    up = true;
    down = false;
  }

  //hides this pie menu
  void hide() {
    startTime  = millis();
    size = 1;
    down = true;
    up = false;
  }

  void update_timer() {

    if (up) {
      //udpating the size
      size =((float)millis() - startTime)/(maxTime*1000);

      /*
      if (size > 2) {
       println("WTF! ");
       println("  millis after: " + temp);
       println("  startTime: " + startTime);
       println("  maxTime: " + maxTime);
       }
       */

      //if finished
      if (size > 1)
        up = false;
    }

    if (down) {
      //udpating the size
      size =((float)millis() - startTime)/(maxTime*1000);
      size = maxTime-size;

      //if finished
      if (size < 0) {
        down = false;
        is_showing = false;
      }
    }

    //println(size);
  }

  //sets the diam and the textdiam
  void set_diam (int newdiam) {
    this.diam           = newdiam;
    this.textdiam       = this.diam/2.5;
    this.innerCircleDiam= this.diam/4;
  }

  //sets the diam of the inner circle
  void set_inner_circle_diam (int newdiam) {
    this.innerCircleDiam = newdiam;
  }

  //sets the x/y position of this pie menu
  void set_position (int x, int y) {
    this.x = x;
    this.y = y;
  }

  void draw () {
    pushMatrix();
    translate(this.x, this.y);
    update_timer();
    scale(size);
    draw_menu();
    popMatrix();
  }

  //draws the pie menu
  void draw_menu() {
    //if it' not showing, return!
    if (!is_showing) return;

    noStroke();
    fill(125);

    float mouseTheta = atan2(mouseY-this.y, mouseX-this.x);
    float piTheta    = mouseTheta>=0?mouseTheta:mouseTheta+TWO_PI;
    float op         = options.length/TWO_PI;

    this.selected = -1;

    for (int i=0; i<options.length; i++) {
      //compute the proper angles
      float s = i/op-(PI/this.options.length);
      float e = (i+0.98)/op-(PI/this.options.length);

      //if it's a empty option, make it black
      if (this.options[i].equals("")) fill(0);
      //otherwise, make it interactive as part of the pie menu
      else {
        //float s = i/op-PI*0.125;
        //float e = (i+0.98)/op-PI*0.125;
        if (piTheta>= s && piTheta <= e && is_a_point_inside_the_menu(mouseX, mouseY) && (!is_a_point_inside_the_core_circle(mouseX, mouseY))) {
            fill(active_color);
            selected = i;
        } else
          fill(background_color);
      }
      //arc(this.x, this.y, diam, diam, s, e);
      arc(0, 0, diam, diam, s, e);
      //should fill the same color as the background
      //fill(0);
      //ellipse(0, 0, innerCircleDiam, innerCircleDiam);
    }

    fill(font_color);
    textAlign(CENTER, CENTER);

    for (int i=0; i<options.length; i++) {
      float m = i/op;
      text(options[i], cos(m)*textdiam, sin(m)*textdiam);
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
}
