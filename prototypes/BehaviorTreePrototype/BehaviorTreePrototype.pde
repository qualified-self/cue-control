import oscP5.*;
import netP5.*;
import ddf.minim.*;
import javax.script.*;

OscP5 oscP5;
NetAddress remoteLocation;
Minim minim;

Blackboard board = new Blackboard();
BaseNode root;

final int INDENT = 30;
final int NODE_HEIGHT = 25;
final int NODE_SPACING = 5;

final int OSC_SEND_PORT = 12000;
final int OSC_RECV_PORT = 14000;

final color DECORATOR_FILL_COLOR = #555555;
final color DECORATOR_TEXT_COLOR = #eeeeee;

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
                .addChild(new BlackboardSetNode("invented", "1000"))
                .addChild(new ProbabilityNode("random event")
                  .addChild(new BlackboardSetNode("start", "1"))
                  .addChild(new BlackboardSetNode("start", "0"))
                )
                .addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition(' ')))))
                .addChild(new SoundCueNode("123go.mp3"))
                .addChild(new ParallelNode("Start the show", true, true)
                  .addChild(new OscToBlackboard("/cue-proto/start", "start", State.SUCCESS).setDecorator(new WhileDecorator(new ExpressionCondition("[end] == 0"))))
                  .addChild(new OscToBlackboard("/cue-proto/level", "level", State.SUCCESS).setDecorator(new WhileDecorator(new ExpressionCondition("[end] == 0"))))
                  .addChild(new SequentialNode("Start the show")
                    .addChild(new OscCueNode("/curtain/on", 0, 2, 1))
                    .addChild(new OscCueNode("/lights/on", 1, 2, 1))
                    .addChild(new SelectorNode(false)
                      .addChild(new OscCueNode("/show/start", 0, 3, 1)
                                  .setDecorator(new GuardDecorator(new ExpressionCondition("[start] == 1"))))
                      .addChild(new ParallelNode("Error: try again using emergency procedure")
                        .addChild(new SoundCueNode("error.mp3"))
                        .addChild(new OscCueNode("/show/startagain", 0, 2, 1))
                        )
                      )
                    .addChild(new ConstantNode(State.SUCCESS).setDecorator(new WhileDecorator(new NotCondition(new KeyCondition('S')))))
                    .addChild(new ParallelNode("Stop the show")
                      .addChild(new SoundCueNode("stop.mp3"))
                      .addChild(new OscCueNode("/curtain/off", 1, 2, 1))
                      .addChild(new OscCueNode("/lights/off", 0, 2, 1))
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

int drawDecorator(Decorator dec, int x, int y)
{
  if (dec.hasDecorator())
    y = drawDecorator(dec.getDecorator(), x, y);

  // Draw decorator.
  rectMode(CORNERS);
  fill(DECORATOR_FILL_COLOR);
  rect(x, y, width-INDENT, y+NODE_HEIGHT, 10, 10, 0, 0);
  fill(DECORATOR_TEXT_COLOR);
  textSize(NODE_HEIGHT/2);
  text(dec.type() + " " + dec.getDescription(), x+INDENT/2, y+NODE_HEIGHT*0.65);
  y += NODE_HEIGHT;

  return y;
}

int drawNode(BaseNode node, int x, int y)
{
  // Draw decorators (if any).
  if (node.hasDecorator())
  {
    y = drawDecorator(node.getDecorator(), x, y);
  }

  // Draw node.
  rectMode(CORNERS);
  fill(stateToColor(node.getState()));
  int topCorners = node.hasDecorator() ? 0 : 10;
  rect(x, y, width-INDENT, y+NODE_HEIGHT, topCorners, topCorners, 10, 10);

  // Animation for running nodes.
  if (node.getState() == State.RUNNING) {
    final int SPREAD=100;
    int start = x+frameCount%SPREAD;
    int end   = width-INDENT-SPREAD;
    for (int xx=start; xx<end; xx+=SPREAD) {
      fill(255, 255, 255, map(xx, start, end, 100, 0));
      rect(xx, y, xx+SPREAD*0.5, y+NODE_HEIGHT);
    }
  }
  fill(0);
  textSize(NODE_HEIGHT/2);
  text(node.type() + " " + node.getDescription(), x+INDENT/2, y+NODE_HEIGHT*0.65);
  y += NODE_HEIGHT+NODE_SPACING;

  return y;
}

int drawTree(BaseNode node, int x, int y)
{
  // Draw node.
  y = drawNode(node, x, y);

  // Draw children.
  if (node instanceof CompositeNode) {
    CompositeNode cn = (CompositeNode)node;
    for (BaseNode child : cn.children)
    {
      y = drawTree(child, x+INDENT, y);
    }
  }

  return y;
}

color stateToColor(State state) {
  if (state == State.RUNNING)
    return color(#52F3F7);
  else if (state == State.SUCCESS)
    return color(#73FC74);
  else if (state == State.FAILURE)
    return color(#E33535);
  else
    return color(#999999);
}

void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
}