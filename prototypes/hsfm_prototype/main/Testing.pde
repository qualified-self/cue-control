/************************************************
 ** Generic abstract class for testing **********
 ************************************************
 ** jeraman.info, Oct. 3 2016 *******************
 ************************************************
 ************************************************/


abstract class Testing {
  
  PApplet p;
  
  Testing(PApplet p) {
    this.p = p;
  }
  
  abstract void setup();
  abstract void draw();
  void mousePressed(){}
  void mouseReleased(){}
  void keyPressed() {}
}