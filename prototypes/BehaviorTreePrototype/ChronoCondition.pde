class ChronoCondition extends Condition {

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
		return "time left " + (timeOut - chrono.elapsed()/1000.0f);
  }

}
