import processing.core.PApplet;

/// Condition that triggers when a certain time has passed.
public class ChronoCondition extends Condition {

	Chrono chrono;

	float timeOut;

	ChronoCondition(float timeOut) {
		this.timeOut = timeOut;
		chrono = new Chrono(false);
	}

	boolean check(Blackboard agent) {
		return (!chrono.hasPassed((long)(timeOut*1000)));
	}

	Chrono getChrono() { return chrono; }

  public String toString() {
		float timeLeft = timeOut - chrono.elapsed()/1000.0f;
		return "Time left: " + PApplet.nf(PApplet.max(timeLeft, 0), 0, 1) + "s";
  }

}
