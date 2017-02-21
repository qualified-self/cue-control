import controlP5.ControlP5;
import processing.core.PApplet;

/******************************************************************************
 ******************************************************************************
 ** STATE MACHINE PREVIEW ******************************************************************
 ******************************************************************************
 *** jeraman.info, Nov. 25 2016 ***********************************************
 *****************************************************************************/

class StateMachinePreview extends MainCanvas {

	float n;
	float a;
	int x;
	int y;
	int w;
	
	public StateMachinePreview(PApplet p, ControlP5 cp5) {
		super(p, cp5);
		// TODO Auto-generated constructor stub
	}

	/*

  public StateMachinePreview(int x, int y, int w) {
    this.x = x;
    this.y = y;
    this.w = w;
  }

  public void setup(PGraphics pg) {
    n = 1;
  }

  //@TODO replace this method by proper drawing
  public void draw_state_machine() {
    n += 0.01;
    ellipseMode(p.CENTER);
    fill(lerpColor(color(0, 100, 200), color(0, 200, 100), map(sin(n), -1, 1, 0, 1)));
    rect(0, 0, width, height);
    fill(255, 150);
    a+=0.01;
    ellipse(100, 100, abs(sin(a)*200), abs(sin(a)*150));
    ellipse(40, 40, abs(sin(a+0.5)*50), abs(sin(a+0.5)*50));
    ellipse(60, 140, abs(cos(a)*80), abs(cos(a)*80));
  }

  //@TODO implement the zoom to open as you did for the pie menu
  public void draw(PGraphics pg) {
    pushMatrix();
    translate(x+40, y+20);
    pushMatrix();
    rectMode(CENTER);
    //float zoom = map(mouseX, 0, width, 0.1, 1);
    float zoom = 0.1;
    scale(zoom);
    draw_state_machine();
    popMatrix();
    popMatrix();
    rectMode(CORNER);
  }

	 */
}
