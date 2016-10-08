class ProbabilityNode extends CompositeNode
{
	ArrayList<Float> weighting;
	float totalSum;
	BaseNode currentNode;

  ProbabilityNode() {
    this(null);
  }

  ProbabilityNode(String description) {
		super(description);
		weighting = new ArrayList<Float>();
  }

  CompositeNode addChild(BaseNode node) {
		return addChild(1, node);
  }

  CompositeNode addChild(float weight, BaseNode node) {
		weighting.add(new Float(weight));
    children.add(node);

		// Recompute total.
		totalSum = 0;
		for (Float f : weighting)
			totalSum += f.floatValue();
    return this;
  }

  public State doExecute(Blackboard agent)
  {
		//check if we've already chosen a node to run
		if (currentNode != null)
		{
			State status = currentNode.execute(agent);
			if (status != State.RUNNING)
				currentNode = null;
			return status;
		}

		double chosen = random(totalSum); // generate a number between 0 and the sum of the weights

		float sum = 0;
		for (int i=0; i<nChildren(); i++)
		{
			sum += weighting.get(i).floatValue();
			if (sum >= chosen) //execute this node
			{
				println("Chose child: " + i);
				State status = children.get(i).execute(agent);

				if (status == State.RUNNING)
					currentNode = children.get(i);
				else
					currentNode = null;
				return status;
			}
		}

		println("ERROR: This shouldn't happen");
		return State.FAILURE;
  }

  void doInit(Blackboard agent)
  {
		currentNode = null;
    for (BaseNode node : children)
      node.init(agent);
	}

  public String type() { return "PRB"; }
}
