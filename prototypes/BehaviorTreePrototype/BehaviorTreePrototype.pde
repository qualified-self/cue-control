import oscP5.*;
import netP5.*;
import ddf.minim.*;
import javax.script.*;
import java.util.regex.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

OscP5 oscP5;
NetAddress remoteLocation;
Minim minim;

Blackboard board = new Blackboard();
BaseNode root;

NodeFactory factory;

final int INDENT = 50;
final int NODE_HEIGHT = 25;
final int NODE_SPACING = 5;
final int BLACKBOARD_WIDTH = 400;

final int OSC_SEND_PORT = 12000;
final int OSC_RECV_PORT = 14000;
final String OSC_IP     = "192.168.1.101";

final color DECORATOR_FILL_COLOR = #555555;
final color DECORATOR_TEXT_COLOR = #eeeeee;

final color NODE_TEXT_COLOR = #000000;

final color NODE_EXPANSION_BUTTON_COLOR = #333333;

void settings() {
  size(displayWidth-BLACKBOARD_WIDTH, displayHeight);
}

void setup() {
  // Secondary window (for blackboard).
//  String[] args = {"Blackboard"};
  BlackboardApplet sa = new BlackboardApplet();
//  PApplet.runSketch(args, sa);

  noStroke();
//  frameRate(5);

  // Create factory.
  factory = new NodeFactory(this);

  // start oscP5, listening for incoming messages.
  oscP5 = new OscP5(this, OSC_RECV_PORT);

  // location to send OSC messages
  remoteLocation = new NetAddress(OSC_IP, OSC_SEND_PORT);

  minim = new Minim(this);

  board.addTask(new OscBlackboardTask("sensor", "/bitalino/0"));
  board.addTask(new ConditionBlackboardTask("spacebar", new KeyCondition(' ')));
  root = createTree();
  playing = false;
}

State rootState = State.RUNNING;

void draw() {
  // Reset background.
  background(0);

  // Draw tree.
  if (click.wasClicked())
    selectedNode = null;
  drawTree(this, root, INDENT, NODE_HEIGHT);
  click.reset();

  if (playing) {

    // Execute blackboard tasks.
    board.execute();

    // Execute (if running).
    if (rootState == State.RUNNING) {
      rootState = root.execute(board);
    }
  }
}

class MouseClick {
  float x;
  float y;
  boolean clicked;

  MouseClick() { reset(); }

  void reset() { clicked = false; }

  void click() {
    x = mouseX;
    y = mouseY;
    clicked = true;
  }

  boolean wasClicked() { return clicked; }

  boolean roundButtonWasClicked(float bx, float by, float radius)
  {
    return wasClicked() && dist(x, y, bx, by) < radius;
  }

  boolean rectButtonWasClicked(float bx1, float by1, float bx2, float by2) {
    return wasClicked() && (bx1 <= x && x <= bx2 && by1 <= y && y <= by2);
  }
}

BaseNode selectedNode = null;
BaseNode nextSelectedNode = null;
MouseClick click = new MouseClick();

void mouseClicked()
{
  // Register click.
  click.click();
}

void keyPressed() {
  println("key pressed " + key + " " + keyCode);
  println(key == CODED);
  switch (key)
  {
    case ' ':                togglePlay(); break;
    case ENTER: case RETURN: addSibling(); break;
    case DELETE:             removeNode(); break;
    case CODED: {
      switch (keyCode) {
        default:
      }
    }
    break;

    default:
  }
}

void togglePlay() {
  playing = !playing;
}

void addSibling() {
  if (selectedNode != null && selectedNode.hasParent()) {
    BaseNode newNode = new SequentialNode();
    selectedNode.getParent().insertChild(selectedNode, newNode);
    selectedNode = newNode;
  }
}

void removeNode() {
  if (selectedNode != null && selectedNode.hasParent()) {
    selectedNode.getParent().removeChild(selectedNode);
    selectedNode = null;
  }
}

void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
}
