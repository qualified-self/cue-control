import oscP5.*;
import netP5.*;
import ddf.minim.*;
import java.util.regex.*;
import java.util.*;
import java.io.*;

import java.awt.event.KeyEvent;

final int INDENT = 50;
final int NODE_HEIGHT = 25;
final int NODE_SPACING = 5;
final int BLACKBOARD_WIDTH = 600;

final int OSC_SEND_PORT = 12000;
final int OSC_RECV_PORT = 14000;
final String OSC_IP     = "192.168.1.101";

final color DECORATOR_FILL_COLOR = #6a6a6a;
final color DECORATOR_TEXT_COLOR = #eeeeee;

final color NODE_TEXT_COLOR = #000000;

final color NODE_EXPANSION_BUTTON_COLOR = #333333;

OscP5 oscP5;
NetAddress remoteLocation;
Minim minim;
Serializer serializer = new Serializer();

Blackboard board = new Blackboard();
Console console = Console.instance();
CompositeNode root;

NodeFactory factory;

// Are we playing/paused.
boolean playing;

// Are we currently in the process of adding/editing a node.
boolean editing;

// Vertical offset (for scrolling)
float yOffset = 0;

// Placeholder node used to add/edit new nodes.
PlaceholderNode placeholderNode = new PlaceholderNode();

// Autocomplete list.
String autocompleteListCurrentSelected;

public OscP5 oscP5() { return oscP5; }
public Minim minim() { return minim; }

public NetAddress remoteLocation() { return remoteLocation; }

void settings() {
  size(displayWidth-BLACKBOARD_WIDTH, displayHeight, P2D);
}

void setup() {
  // Secondary window (for blackboard).
//  String[] args = {"Blackboard"};
  ConsoleApplet sa = new ConsoleApplet();
//  PApplet.runSketch(args, sa);

  // Iniialize instance.
  inst = this;

  noStroke();
  smooth();
//  frameRate(5);

  // Create factory.
  factory = new NodeFactory();

  // Start oscP5, listening for incoming messages.
  oscP5 = new OscP5(this, OSC_RECV_PORT);

  // Location to send OSC messages
  remoteLocation = new NetAddress(OSC_IP, OSC_SEND_PORT);

  // Start sound server.
  minim = new Minim(this);

  // Initianlize expression/script manager.
  Expression.initManager();

  // Create new/empty structure.
  clear();
//  root = factory.createNode("SelectorNode \"Go man!\" false");
//  root = createTreeCepheids();
//  root = createTreeOtherSelf();
//  root = simpleTest();
//  root = createTreeOct25();
//  root = createTreeOct25();

  // board.put("test1", "1");
  // board.put("test2", "2");
  // board.put("test3", "3");

  // board.addTask(new OscBlackboardTask("/test/sync", "raw_sync"));
  // board.addTask(new ConditionBlackboardTask("spacebar", new ExpressionCondition("$test1 == 1 && $test1 > 0 && $test2 == 2 && $test3 == 3")));
  // board.addTask(new ConditionBlackboardTask("spacebar", new KeyCondition(' ')));
}

State rootState = State.RUNNING;

int nSteps = 0;

void draw() {
  // Reset background.
  background(0);

  if (root != null)
  {
    // Draw tree.
    if (click.wasClicked())
      selectedNode = null;
    drawMainTree(this);
    drawEditor(this);
    click.reset();

    if (isPlaying() && !isEditing()) {

      // Update blackboard values.
      board.put("mouseX", mouseX);
      board.put("mouseY", mouseY);
      board.put("keyPressed", keyPressed);
      board.put("key", keyPressed ? key : 0);

  //    println(nSteps);

      // Execute blackboard tasks.
      board.execute();

      // Execute (if running).
      if (rootState == State.RUNNING) {
        rootState = root.execute(board);
      }

      nSteps++;
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
    click(mouseX, mouseY);
  }

  void click(float x, float y) {
    this.x = x;
    this.y = y;
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
ArrayList<BaseNode> orderedVisibleNodes; // used to maintain list of all nodes in order they appear on screen

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
      case ENTER: case RETURN:
        if (autocompleteListCurrentSelected == null) submitNode();
        else
        {
          placeholderNode.assign(autocompleteListCurrentSelected);
          autocompleteListCurrentSelected = null;
        }
        break;
      case DELETE:             cancelNode(); break;
      case BACKSPACE:          placeholderNode.backspace(); break;
      case TAB:                autocompleteNode(); break;

     case CODED:
     {
       switch (keyCode)
       {
         case UP:   changeSelectedDropdown(-1); break;
         case DOWN: changeSelectedDropdown(+1); break;
       }
     }
     break;

      default:                 placeholderNode.append(key);
    }
  }

  // Otherwise: normal commands.
  else {
    if (keyEvent.isControlDown())
    {
      switch (keyCode)
      {
        case KeyEvent.VK_SPACE:            togglePlay(); break;
        case KeyEvent.VK_R:                reset();      break;
        case KeyEvent.VK_N:                if (keyEvent.isShiftDown()) clear(); break;

        case KeyEvent.VK_O:                serializer.load(); reset(); break;
        case KeyEvent.VK_S:
          if (keyEvent.isShiftDown())
            serializer.saveAs();
          else
            serializer.save();
          reset();
          break;

        case KeyEvent.VK_D:                  addDecorator(); break;

        case KeyEvent.VK_ENTER:
          addSibling();
          break;
        case KeyEvent.VK_TAB:                addChild(); break;
        case KeyEvent.VK_DELETE:             removeNode(); break;

        case KeyEvent.VK_UP:                 moveNodeWithinLevel(-1); break;
        case KeyEvent.VK_DOWN:               moveNodeWithinLevel(+1); break;
        case KeyEvent.VK_LEFT:               moveHigher(); break;
        case KeyEvent.VK_RIGHT:              moveLower(); break;

        default:;
      }
    }
    else
    {
      switch (key)
      {
        case CODED:
        {
          switch (keyCode)
          {
            case KeyEvent.VK_UP:   changeSelected(-1); break;
            case KeyEvent.VK_DOWN: changeSelected(+1); break;
          }
        }
        break;
      }
    }
  }

}

void mouseWheel(MouseEvent e) {
  yOffset += e.getCount() * NODE_HEIGHT;
}

void reset() {
  board.init();
  if (root != null)
    root.init(board);
  rootState = State.RUNNING;
  setPlayState(false);
  setEditState(false);
}

void clear() {
  root = new SequenceNode();

  reset();

  setPlayState(false);
  setEditState(false);
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
    autocompleteListCurrentSelected = null;
//    selectedNode = newNode;
  }
}

void addChild() {
  if ( (selectedNode != null && selectedNode instanceof CompositeNode) || root.nChildren() == 0) {
    setEditState(true);
    placeholderNode.reset();
    if (root.nChildren() == 0)
      selectedNode = root;
    ((CompositeNode)selectedNode).addChild(placeholderNode);
    selectedNode = null;
    autocompleteListCurrentSelected = null;
//    selectedNode = newNode;
  }
}

void addDecorator() {
  if (selectedNode != null) {
    setEditState(true);
    placeholderNode.reset();
    selectedNode.setDecorator(placeholderNode);
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
  if (selectedNode != null) {
    if (selectedNode.hasParent()) {
      selectedNode.getParent().removeChild(selectedNode);
      selectedNode = null;
    }
    else if (selectedNode instanceof Decorator) {
      BaseNode node = ((Decorator)selectedNode).getNode();
      node.removeDecorator();
      selectedNode = node;
    }
  }
}

void autocompleteNode() {
  ArrayList<String> autocompleteOptions = factory.nodesStartingWith(placeholderNode.getDescription(), placeholderNode.isDecorator());
  if (autocompleteOptions.size() == 1)
    placeholderNode.assign(autocompleteOptions.get(0));
}

void changeSelectedDropdown(int move) {
  println("changeleefadfd");
  ArrayList<String> autocompleteOptions = factory.nodesStartingWith(placeholderNode.getDescription(), placeholderNode.isDecorator());
  if (autocompleteListCurrentSelected == null && autocompleteOptions.size() > 0)
    autocompleteListCurrentSelected = autocompleteOptions.get(0);
  else
  {
    int index = autocompleteOptions.indexOf(autocompleteListCurrentSelected);
    println("index:" + index);
    if (index >= 0)
    {
      index = constrain(index +  move, 0, autocompleteOptions.size()-1);
      autocompleteListCurrentSelected = autocompleteOptions.get(index);
      println("new: " + autocompleteListCurrentSelected);
    }
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

void changeSelected(int move) {
  if (selectedNode == null || orderedVisibleNodes == null)
  {
    selectedNode = root;
  }
  else
  {
    int index = orderedVisibleNodes.indexOf(selectedNode);
    if (index >= 0)
    {
      selectedNode = orderedVisibleNodes.get( constrain(index + move, 0, orderedVisibleNodes.size()-1));
    }
  }
}

void moveHigher() {
  if (selectedNode != null && selectedNode.hasParent() && selectedNode.getParent().hasParent()) {
    CompositeNode parent = selectedNode.getParent();
    CompositeNode grandParent = parent.getParent();
    parent.removeChild(selectedNode);
    grandParent.insertChild(parent, selectedNode);
  }
}

void moveLower() {
  if (selectedNode != null && selectedNode.hasParent() & selectedNode.getParent().nChildren() > 0) {
    CompositeNode parent = selectedNode.getParent();
    int index = parent.indexOf(selectedNode);
    if (index > 0) {
      BaseNode siblingNode = parent.getChild(index-1);
      if (siblingNode instanceof CompositeNode) {
        parent.removeChild(selectedNode);
        ((CompositeNode)siblingNode).addChild(selectedNode);
      }
    }
  }
}

void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
}

private static BehaviorTreePrototype inst;

public static BehaviorTreePrototype instance() {
  return inst;
}
