class ChronoBlackboardTask extends BlackboardTask
{
	String varName;
  Chrono chrono;

	ChronoBlackboardTask(String varName)
	{
    super();
		this.varName = varName;
    chrono = new Chrono(false);
	}

  void init(Blackboard agent) {
    agent.put(varName, 0);
    chrono.restart();
  }

	void execute(Blackboard agent)
	{
		agent.put(varName, chrono.seconds());
	}
}
