import controlP5.Canvas;
import processing.core.PGraphics;

/******************************************************************************
 ******************************************************************************
 ** STATE MACHINE PREVIEW ******************************************************************
 ******************************************************************************
 *** jeraman.info, Nov. 25 2016 ***********************************************
 *****************************************************************************/

class StateMachinePreview extends Canvas {

	ZenStates 	 p;
	StateMachine sm; //the state machine to be previewed
	CircleEffectUI animation;
	
	float n;
	float a;
	int x;
	int y;

	public StateMachinePreview(ZenStates p, StateMachine sm, int x, int y) {
		this.p = p;
		this.sm = sm;
		this.x = x;
		this.y = y;
		this.animation = new CircleEffectUI(p, x, y);
	}

	public void setup(PGraphics pg) {
		n = 1;
	}

	public void draw_state_machine() {
		p.ellipseMode(p.CENTER);
		p.fill(15);
		p.rect(0, 0, p.width, p.height);
		p.pushMatrix();
		p.translate(-p.width/2, -p.height/2);
		sm.draw();
		p.popMatrix();
	}

	//@TODO implement the zoom to open as you did for the pie menu
	public void draw(PGraphics pg) {
		p.pushMatrix();
		p.translate(x+45, y+30);
		//p.translate(x, y);
		p.pushMatrix();
		p.rectMode(p.CENTER);
		//float zoom = p.map(p.mouseX, 0, p.width, 0.1f, 1);
		float zoom = 0.09f;
		p.scale(zoom);
		//drawing the state machine preview
		draw_state_machine();
		//drawing the animation, if necessary
		p.popMatrix();
		this.animation.draw();
		p.popMatrix();
		p.rectMode(p.CORNER);
	}
	
	public void open() {
		animation.open();
	}
	
	public void close() {
		animation.close();
	}


}
