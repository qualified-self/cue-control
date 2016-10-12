import oscP5.*;
import netP5.*;
import ddf.minim.*;
import javax.script.*;

OscP5 oscP5;
NetAddress remoteLocation;
Minim minim;

Blackboard board = new Blackboard();
BaseNode root;

final int INDENT = 50;
final int NODE_HEIGHT = 25;
final int NODE_SPACING = 5;

final int OSC_SEND_PORT = 12000;
final int OSC_RECV_PORT = 14000;

final color DECORATOR_FILL_COLOR = #555555;
final color DECORATOR_TEXT_COLOR = #eeeeee;

final color NODE_TEXT_COLOR = #000000;

void settings() {
  size(1000, 1000);
}

void setup() {
  // Secondary window (for blackboard).
//  String[] args = {"Blackboard"};
  BlackboardApplet sa = new BlackboardApplet();
//  PApplet.runSketch(args, sa);

  noStroke();
//  frameRate(5);

  // start oscP5, listening for incoming messages.
  oscP5 = new OscP5(this, OSC_RECV_PORT);

  // location to send OSC messages
  remoteLocation = new NetAddress("127.0.0.1", OSC_SEND_PORT);

  minim = new Minim(this);

  // board.put("test", 0);
  // board.put("test2", 10);

  root = new SequentialNode("Wait for starting cue then launch")
                .addChild(new BlackboardSetNode("end", "0"))
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

State rootState = State.RUNNING;

void draw() {
  background(0);

  if (rootState == State.RUNNING) {
    rootState = root.execute(board);
  }

  drawTree(root, INDENT, NODE_HEIGHT);
}

void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
}
