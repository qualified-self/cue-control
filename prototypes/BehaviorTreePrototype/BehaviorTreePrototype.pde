import oscP5.*;
import netP5.*;
import ddf.minim.*;
import java.util.regex.*;
import java.util.*;
import java.io.*;

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

OscP5 oscP5;
NetAddress remoteLocation;
Minim minim;
Serializer serializer = new Serializer();

Blackboard board = new Blackboard();
BaseNode root;

NodeFactory factory;

// Are we playing/paused.
boolean playing;

// Are we currently in the process of adding/editing a node.
boolean editing;

// Vertical offset (for scrolling)
float yOffset = 0;

// Placeholder node used to add/edit new nodes.
PlaceholderNode placeholderNode = new PlaceholderNode();

public OscP5 oscP5() { return oscP5; }
public Minim minim() { return minim; }
public NetAddress remoteLocation() { return remoteLocation; }

void settings() {
  size(displayWidth-BLACKBOARD_WIDTH, displayHeight);
}

void setup() {
  // Secondary window (for blackboard).
//  String[] args = {"Blackboard"};
  BlackboardApplet sa = new BlackboardApplet();
//  PApplet.runSketch(args, sa);

  // Iniialize instance.
  inst = this;

  noStroke();
//  frameRate(5);

  // Create factory.
  factory = new NodeFactory();

  // start oscP5, listening for incoming messages.
  oscP5 = new OscP5(this, OSC_RECV_PORT);

  // location to send OSC messages
  remoteLocation = new NetAddress(OSC_IP, OSC_SEND_PORT);

  minim = new Minim(this);

  root = new SequentialNode();
  board.addTask(new OscBlackboardTask("sensor", "/bitalino/0"));
  board.addTask(new ConditionBlackboardTask("spacebar", new KeyCondition(' ')));
  reset();

  setPlayState(false);
  setEditState(false);
}

State rootState = State.RUNNING;

int nSteps = 0;

void draw() {
  // Reset background.
  background(0);

  // Draw tree.
  if (click.wasClicked())
    selectedNode = null;
  drawTree(this, root, INDENT, (int)yOffset+NODE_HEIGHT);
  click.reset();

  if (isPlaying() && !isEditing()) {
    println(nSteps);

    // Execute blackboard tasks.
    board.execute();

    // Execute (if running).
    if (rootState == State.RUNNING) {
      rootState = root.execute(board);
    }

    nSteps++;
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
  // Special case: input information for new node.
  if (isEditing()) {
    switch (key)
    {
      case CODED: break;
      case ENTER: case RETURN: submitNode(); break;
      case DELETE:             cancelNode(); break;
      case BACKSPACE:          placeholderNode.backspace(); break;
      default:                 placeholderNode.append(key);
    }
  }

  // Otherwise: normal commands.
  else {
    switch (key)
    {
      case ' ':                togglePlay(); break;
      case 'R':                reset();      break;
      case 'L':                serializer.load(); reset(); break;
      case 'S':                serializer.save(); reset(); break;
      case 'D':                serializer.saveAs(); reset(); break;
      case ENTER: case RETURN: addSibling(); break;
      case TAB:                addChild(); break;
      case DELETE:             removeNode(); break;
      case CODED: {
        switch (keyCode) {
          case UP:             moveNodeWithinLevel(-1); break;
          case DOWN:           moveNodeWithinLevel(+1); break;
          default:
        }
      }
      break;

      default:
    }
  }
}

void mouseWheel(MouseEvent e) {
  yOffset += e.getCount() * NODE_HEIGHT;
}

void reset() {
  println("RESET");
  root.init(board);
  rootState = State.RUNNING;
  pause();
}

boolean isPlaying() {
  return playing;
}

boolean isEditing() {
  return editing;
}

void setPlayState(boolean playing) {
  this.playing = playing;
}

void setEditState(boolean editing) {
  this.editing = editing;
}

void togglePlay() {
  playing = !playing;
}

void play() {
  setPlayState(true);
}

void pause() {
  setPlayState(false);
}

void addSibling() {
  if (selectedNode != null && selectedNode.hasParent()) {
    setEditState(true);
    placeholderNode.reset();
    selectedNode.getParent().insertChild(selectedNode, placeholderNode);
    selectedNode = null;
//    selectedNode = newNode;
  }
}

void addChild() {
  if (selectedNode != null && selectedNode instanceof CompositeNode) {
    setEditState(true);
    placeholderNode.reset();
    ((CompositeNode)selectedNode).addChild(placeholderNode);
    selectedNode = null;
//    selectedNode = newNode;
  }
}

void submitNode() {
  BaseNode newNode = placeholderNode.submit();
  if (newNode != null) {
   setEditState(false);
   selectedNode = newNode;
  }
}

void cancelNode() {
  placeholderNode.cancel();
  setEditState(false);
}

void removeNode() {
  if (selectedNode != null && selectedNode.hasParent()) {
    selectedNode.getParent().removeChild(selectedNode);
    selectedNode = null;
  }
}

void moveNodeWithinLevel(int move) {
  println("Move withinlevel: " + move);
  if (selectedNode != null && selectedNode.hasParent()) {
    CompositeNode parent = selectedNode.getParent();
    int index = parent.indexOf(selectedNode);
    int nextIndex = constrain(index + move, 0, parent.nChildren()-1);
    println("from " + index + " to "+nextIndex);
    parent.moveChild(index, nextIndex);
  }
}

void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
}

public static String stateToString(State state) {
	if (state == State.RUNNING) return "RUNNING";
	else if (state == State.SUCCESS) return "SUCCESS";
	else if (state == State.FAILURE) return "FAILURE";
	else return "UNDEFINED";
}

private static BehaviorTreePrototype inst;

public static BehaviorTreePrototype instance() {
  return inst;
}
