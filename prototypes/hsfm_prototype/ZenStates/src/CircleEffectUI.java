/************************************************
 ** UI Effect for opening and closing a certain *
 ** substate machine ****************************
 ************************************************
 ** jeraman.info, Feb. 22 2017 ******************
 ************************************************
 ************************************************/


class CircleEffectUI {

	ZenStates 	 p;
	CircleStatus circle_status;
	StateMachine parent;
	
	int duration  = 500;
	int timestamp = 0;
	float size;

	int x;
	int y;

	public CircleEffectUI(ZenStates p, StateMachine m, int x, int y) {
		this.p 		= p;
		this.parent = m;
		this.x = x;
		this.y = y;

		this.setup();
	}

	void setup() {
		//is_opening = false;
		circle_status = CircleStatus.CLOSED;
		timestamp = 0;
	}

	void draw() {
		//if this is not opening, dont bother
		if (!is_opening_or_closing ()) return; 

		update_timer();

		//p.println(size);
		p.strokeWeight(25);
		p.stroke(150);
		p.fill(0);
		p.ellipse(this.x, this.y, size, size);
	}

	void set_position (int x, int y) {
		this.x = x;
		this.y = y;
	}

	void open() {
		timestamp     = p.millis();
		circle_status = CircleStatus.OPENING;
		size = 0;
	}

	void close() {
		timestamp     = p.millis();
		circle_status = CircleStatus.CLOSING;
		size = 1;
	}

	void update_timer() {
		//if this is not opening, dont bother
		if (!is_opening_or_closing ()) return; 

		//if is opening
		if (is_opening()) {
			int time_elapsed = p.abs(p.millis()-timestamp);
			if (time_elapsed > duration) { //if reached the end, stops counter
				//p.println("Open!");
				circle_status = CircleStatus.OPEN;
				size = 1;
				p.canvas.push_root(parent);
			} else  //otherwise, keep updating size
				size = (time_elapsed*1f/duration)*2*p.width;
		}

		//if is closing
		if (is_closing()) {
			int time_elapsed = p.abs(p.millis()-timestamp);
			if (time_elapsed > duration) { //if reached the end, stops counter
				p.println("Closed!");
				circle_status = CircleStatus.CLOSED;
				size = 0;
				//does not need to pop, because, the root was already popped
				//p.canvas.pop_root();
			} else { //otherwise, keep updating size
				time_elapsed = duration - time_elapsed;
				size = (time_elapsed*1f/duration)*2*p.width;
			}
		}
	}

	boolean is_opening_or_closing () {
		return (is_opening() || is_closing());
	}

	boolean is_opening() {
		return circle_status==CircleStatus.OPENING;
	}

	boolean is_closing() {
		return circle_status==CircleStatus.CLOSING;
	}
}
