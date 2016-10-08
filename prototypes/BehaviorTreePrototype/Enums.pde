public static enum State {
	RUNNING,
	SUCCESS,
	FAILURE,
	UNDEFINED
}

String stateToString(State state) {
	if (state == State.RUNNING) return "RUNNING";
	else if (state == State.SUCCESS) return "SUCCESS";
	else if (state == State.FAILURE) return "FAILURE";
	else return "UNDEFINED";
}
