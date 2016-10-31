class ProbabilityNode extends CompositeNode
{
	ArrayList<Expression> weighting;
	float totalSum;
	BaseNode currentNode;

  ProbabilityNode() {
    this(null);
  }

  ProbabilityNode(String description) {
		super(description);
		weighting = new ArrayList<Expression>();
  }

  ProbabilityNode addChild(BaseNode node) {
		return addChild(1, node);
  }

	// todo: weight could be a blackboard element
  ProbabilityNode addChild(Expression weight, BaseNode node) {
		weighting.add(weight);
    children.add(node);
    return this;
	}

  ProbabilityNode addChild(String weight, BaseNode node) {
		return addChild(new Expression(weight), node);
	}

  ProbabilityNode addChild(float weight, BaseNode node) {
		return addChild(new Expression(String.valueOf(weight)), node);
  }

	ProbabilityNode setDecorator(Decorator decorator) {
		return (ProbabilityNode)super.setDecorator(decorator);
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

		// Compute total sum and "freeze" weights.
		float[] frozenWeighting = new float[nChildren()];
		float totalSum = 0;
		try {
			for (int i=0; i<nChildren(); i++)
				totalSum += ( frozenWeighting[i] = max((float)weighting.get(i).evalAsDouble(agent).doubleValue(), 0) );
		} catch (ScriptException e) {
			return State.FAILURE;
		}

		// Generate a number between 0 and the sum of the weights
		float chosen = (float)random(totalSum);

		float sum = 0;
		for (int i=0; i<nChildren(); i++)
		{
			sum += frozenWeighting[i];
			if (sum >= chosen) //execute this node
			{
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
