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
final int NODE_HEIGHT = 30;
final int NODE_SPACING = 5;

final int OSC_SEND_PORT = 12000;
final int OSC_RECV_PORT = 14000;

final color DECORATOR_FILL_COLOR = #555555;
final color DECORATOR_TEXT_COLOR = #eeeeee;

void setup() {
  size(800, 600);
  frameRate(10);

  // start oscP5, listening for incoming messages.
  oscP5 = new OscP5(this, OSC_RECV_PORT);

  // location to send OSC messages
  remoteLocation = new NetAddress("127.0.0.1", OSC_SEND_PORT);

  minim = new Minim(this);

  board.put("test", 0);
  board.put("test2", 10);

  root = new ParallelNode("Play sound and show", true, true)
                  .addChild(new SoundCueNode("123go.mp3")
                                .setDecorator(new GuardDecorator(new NotCondition(new KeyCondition(' ')))))
                  .addChild(new SequentialNode()
                    .addChild(new OscCueNode("/curtain/on", 0, 2, 1))
                    .addChild(new OscCueNode("/lights/on", 1, 2, 1))
                    .addChild(new SelectorNode(false)
                      .addChild(new OscCueNode("/show/start", 0, 3, 1)
                                  .setDecorator(new GuardDecorator(new BlackboardCondition("[test] > 0"))))
                      .addChild(new ParallelNode()
                        .addChild(new SoundCueNode("error.mp3"))
                        .addChild(new OscCueNode("/show/startagain", 0, 2, 1))))
                    .addChild(new ParallelNode()
                      .addChild(new SoundCueNode("stop.mp3"))
                      .addChild(new OscCueNode("/curtain/off", 1, 2, 1))
                      .addChild(new OscCueNode("/lights/off", 0, 2, 1))));
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
  text(dec.type() + " " + dec.getDescription(), x+INDENT/2, y+NODE_HEIGHT/2);
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
  fill(0);
  textSize(NODE_HEIGHT/2);
  text(node.type() + " " + node.getDescription(), x+INDENT/2, y+NODE_HEIGHT/2);
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
  else
    return color(#E33535);
}
