/************************************************
 ** This class was created to group several util things
 ** such as osc setup and control-5.
 ************************************************
 ** OBS: osc in the future needs to be integrated with the blackboard
 ************************************************
 ** jeraman.info, Oct. 11 2016 ******************
 ************************************************
 ************************************************/

////////////////////////////////////////
//importing whatever we need
import ddf.minim.*;
import oscP5.*;
import netP5.*;
import controlP5.*;

//my osc variables
OscP5 oscP5;

//my controlP5 variable for gui
ControlP5 cp5;

//system's default port for receiveing osc messages
final int OSC_RECV_PORT = 14000;

//calls all other utils
void setup_util() {
  setup_osc();
  setup_control_p5(); 
}

//function for setting up osc
void setup_osc () {
  // start oscP5, listening for incoming messages.
  oscP5 = new OscP5(this, OSC_RECV_PORT);
}

//@TODO - integrate that with the Blackboard
//adding input osc support similar to Sofian's
void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
}

//function for setting up controlp5
void setup_control_p5 () {
  cp5 = new ControlP5(this);
}