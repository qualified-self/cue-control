import java.lang.reflect.*;

BaseNode createNode(String str) {
  // Split list in tokens.
  // Source: http://stackoverflow.com/questions/7804335/split-string-on-spaces-in-java-except-if-between-quotes-i-e-treat-hello-wor
  List<String> list = new ArrayList<String>();
  Matcher m = Pattern.compile("([^\"]\\S*|\".+?\")\\s*").matcher(str);
  while (m.find())
    list.add(m.group(1).replace("\"", "")); // Add .replace("\"", "") to remove surrounding quotes.

  // Wrong statement.
  if (list.isEmpty()) {
    println("Invalid empty string.");
    return null;
  }

  String classType = list.get(0);

  int nArguments = list.size()-1;
  String[] arguments = new String[nArguments];
  for (int i=0; i<nArguments; i++) {
    arguments[i] = list.get(i+1);
  }

  return createNode(classType, arguments);
}

BaseNode createNode(String classType, String[] arguments)
{
  // Convert arguments to objects.
  int nArguments = arguments.length;
  Object[] argumentObjects = new Object[nArguments+1];
  Class[] argumentClasses  = new Class[nArguments+1];
  argumentObjects[0] = this;
  argumentClasses[0] = this.getClass();
  for (int i=0; i<nArguments; i++) {
    try {
      Expression expr = new Expression(arguments[i]);
      Object obj = expr.eval();
      argumentObjects[i+1] = obj;
      argumentClasses[i+1] = obj.getClass();
    } catch (ScriptException e) {
      argumentObjects[i+1] = arguments[i];
      argumentClasses[i+1] = String.class;
    }
  }

  // Try to generate new instance.
  try {
    // Gather all constructors.
    classType = this.getClass().getName() + "$" + classType;
    Class<?> nodeClass = Class.forName(classType);
    Constructor<?>[] constructors = nodeClass.getConstructors();
    for (Constructor<?> c : constructors)
    {
      // Try each constructor with arguments.
      try {
        return (BaseNode) c.newInstance(argumentObjects);
      }
      catch (IllegalArgumentException e) {}
    }
    println("No valid constructor found for arguments.");
    println("Classtype = " + classType);
    println("Arguments = " + argumentObjects);

    return null;
    // Call constructor.
  } catch (Exception e) {
      println("ERROR: error creating node of class " + classType + ".");
      println(e);
      return null;
  }
}

BaseNode createTree() {
	return new SequentialNode("Wait for starting cue then launch")
							.addChild(new BlackboardSetNode("end", "0"))
							.addChild(new BlackboardSetNode("counter", "0"))
							.addChild(new BlackboardSetNode("invented", "1000"))
							.addChild(new ProbabilityNode("random event")
								.addChild(70, new BlackboardSetNode("start", "1"))
								.addChild(30, new BlackboardSetNode("start", "0"))
							)
							.addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition(' ')))))
							.addChild(new SoundCueNode("123go.mp3"))
							.addChild(new ParallelNode("Start the show", true, true)
								.addChild(new SequentialNode("Stuff running in background").setDecorator(new WhileDecorator(new ExpressionCondition("[end] == 0")))
									.addChild(new OscReceiveNode("/cue-proto/start", "start", State.SUCCESS))
									.addChild(new OscReceiveNode("/cue-proto/level", "level", State.SUCCESS))
									.addChild(new BlackboardSetNode("counter", "[counter]+0.001"))
									.addChild(new BlackboardSetNode("volume", "math.sin( [counter] )"))
								)
								.addChild(new SequentialNode("Start the show")
									.addChild(new OscSendNode("/curtain/on", "1"))
									.addChild(new OscSendNode("/lights/on", "1"))
									.addChild(new OscSendNode("/test/start", "[start] * 2"))
									.addChild(new SelectorNode(false)
										.addChild(new OscSendNode("/show/start", 0, 1)
																.setDecorator(new GuardDecorator(new ExpressionCondition("[start] == 1"))))
										.addChild(new ParallelNode("Error: try again using emergency procedure")
											.addChild(new SoundCueNode("error.mp3"))
											.addChild(new OscSendNode("/show/startagain", 0, 1))
											)
										)
									.addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition('S')))))
									.addChild(new ParallelNode("Stop the show")
										.addChild(new SoundCueNode("stop.mp3"))
										.addChild(new OscSendNode("/curtain/on", "0", 1, 1))
										.addChild(new OscSendNode("/lights/on", "0", 0, 1))
										)
									.addChild(new BlackboardSetNode("end", "1"))
									)
								);
}
