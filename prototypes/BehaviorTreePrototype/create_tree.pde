BaseNode createTree() {
	return new SequentialNode("Wait for starting cue then launch")
							.addChild(new BlackboardSetNode("end", "0"))
							.addChild(new BlackboardSetNode("invented", "1000"))
							.addChild(new ProbabilityNode("random event")
								.addChild(1, new BlackboardSetNode("start", "1"))
								.addChild(100, new BlackboardSetNode("start", "0"))
							)
							.addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition(' ')))))
							.addChild(new SoundCueNode("123go.mp3"))
							.addChild(new ParallelNode("Start the show", true, true)
								.addChild(new OscReceiveNode("/cue-proto/start", "start", State.SUCCESS).setDecorator(new WhileDecorator(new ExpressionCondition("[end] == 0"))))
								.addChild(new OscReceiveNode("/cue-proto/level", "level", State.SUCCESS).setDecorator(new WhileDecorator(new ExpressionCondition("[end] == 0"))))
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
										.addChild(new BlackboardSetNode("end", "1"))
										)
									)
								);
}
