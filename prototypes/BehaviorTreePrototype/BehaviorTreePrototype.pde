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

final int OSC_SEND_PORT = 12000;
final int OSC_RECV_PORT = 14000;

final int BT_RUNNING = 0;
final int BT_SUCCESS = 1;
final int BT_FAILURE = 2;

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
                  .addChild(new SoundCueNode("123go.mp3", 1, 0)
                                .setDecorator(new GuardDecorator(new NotCondition(new KeyCondition(' ')))))
                  .addChild(new SequentialNode()
                    .addChild(new OscCueNode("/curtain/on", 0, 2, 1))
                    .addChild(new OscCueNode("/lights/on", 1, 2, 1))
                    .addChild(new SelectorNode(false)
                      .addChild(new OscCueNode("/show/start", 0, 3, 1)
                                  .setDecorator(new GuardDecorator(new BlackboardCondition("[test] > 0"))))
                      .addChild(new ParallelNode()
                        .addChild(new SoundCueNode("error.mp3", 1, 0))
                        .addChild(new OscCueNode("/show/startagain", 0, 2, 1))))
                    .addChild(new ParallelNode()
                      .addChild(new OscCueNode("/curtain/off", 1, 2, 1))
                      .addChild(new OscCueNode("/lights/off", 0, 2, 1))));
}

int rootState = BT_RUNNING;

void draw() {
  background(0);

    rootState = root.execute(board);
/*  if (rootState == BT_RUNNING) {
    rootState = root.execute(board);
  }
  */
  drawTree(root, INDENT, NODE_HEIGHT);
}

int drawTree(BaseNode node, int x, int y)
{
  // Draw node.
  rectMode(CORNERS);
  fill(stateToColor(node.getState()));
  rect(x, y, width-INDENT, y+NODE_HEIGHT, 0, 10, 10, 10);
  fill(0);
  textSize(NODE_HEIGHT/2);
  text(node.type() + " " + node.getDescription(), x+INDENT/2, y+NODE_HEIGHT/2);
  y += NODE_HEIGHT;

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

color stateToColor(int state) {
  if (state == BT_RUNNING)
    return color(#52F3F7);
  else if (state == BT_SUCCESS)
    return color(#73FC74);
  else
    return color(#E33535);
}
