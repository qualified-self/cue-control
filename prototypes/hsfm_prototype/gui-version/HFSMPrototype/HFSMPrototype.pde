/************************************************
 ** My main!
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/


MainCanvas canvas     ;
Blackboard board      ;
Serializer serializer = new Serializer();

boolean debug = false;
boolean keyReleased = false;
boolean mouseReleased = false;
boolean is_loading = false;

void setup() {
  is_loading = true;
  size(1024,600);
  background(0);
  smooth();
  inst = this;
  setup_util();
  board  = new Blackboard(this);
  canvas = new MainCanvas(this, cp5);

  textSize(cp5.getFont().getSize());
  textFont(cp5.getFont().getFont());

  is_loading = false;
}

void draw() {
  background(0);

  //if is loading an open patch, do not draw anything
  if (is_loading) {
    fill(255);
    textAlign(CENTER);
    text("loading... please, wait.", width/2, height/2);
    return;
  }


  //updates global variables in the bb
  board.update_global_variables();
  //draws the scenario
  canvas.draw();
  //draws the blackboard
  board.draw();

  if (keyReleased)     keyReleased = false;
  if (mouseReleased) mouseReleased = false;
}

void keyPressed(){
  //if is loading an open patch, do not draw anything
  if (is_loading) return;

  switch(key) {
  case '+':
    //create_state();
    canvas.process_plus_key_pressed();
    break;
  case '-':
    //remove_state();
    canvas.process_minus_key_pressed();
    break;

  /*
  case ' ':
    canvas.run();
    break;
  case 's':
    canvas.stop();
    break;
  case 'z':
    serializer.save();
    break;
  case 'x':
    serializer.load();
    break;
  */
  }
  //println(keyCode);
}

void mousePressed() {
  //if is loading an open patch, do not draw anything
  if (is_loading) return;
  //if the key is not pressed, i'm not interested
  if (!keyPressed) return;

  switch(keyCode) {
  //in case the key it's shift
  case 16:
    canvas.process_shift_key();
    break;
  }
}

void keyReleased() {
  keyReleased = true;
}

void mouseReleased() {
  mouseReleased = true;
}

//checks if the user released the key minus
public boolean user_pressed_minus () {
  boolean result = keyReleased && key=='-';
  //returns the result
  return result;
}


//callback functions
void button_play() {
  if (is_loading) return;
  println("b_play pressed");
  canvas.run();
}

void button_stop() {
  if (is_loading) return;
  println("b_stop pressed");
  canvas.stop();
}
void button_save() {
  if (is_loading) return;
  println("b_save pressed");
  serializer.save();
}

void button_load() {
  if (is_loading) return;
  println("b_load pressed");
  serializer.load();
}


/*
public void b_new() {
  println("b_new pressed");
}
*/

///////////////////////////////////////////////////
//the following code was taken from Sofians' prototype
//the goal is to allow serialization

public OscP5 oscP5() { return oscP5; }
public ControlP5 cp5() { return cp5; }
public Minim minim() { return minim; }
public Blackboard board() { return board; }
public MainCanvas canvas() { return canvas; }
public boolean debug() {return debug; }
//public NetAddress remoteLocation() { return remoteLocation; }

private static HFSMPrototype inst;

public static HFSMPrototype instance() {
  return inst;
}
