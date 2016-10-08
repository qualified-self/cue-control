public static enum State {
	RUNNING,
	SUCCESS,
	FAILURE
}

String stateToString(State state) {
	if (state == State.RUNNING) return "RUNNING";
	else if (state == State.SUCCESS) return "SUCCESS";
	else return "FAILURE";
}
