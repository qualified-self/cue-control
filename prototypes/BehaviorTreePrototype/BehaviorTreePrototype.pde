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

  root = createTree();
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