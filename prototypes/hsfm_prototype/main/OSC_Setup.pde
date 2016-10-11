/************************************************
 ** This class was created to support incoming osc message.
 ** in the future this will be integrated with the blackboard
 ************************************************
 ** jeraman.info, Oct. 11 2016 ******************
 ************************************************
 ************************************************/

//my osc variables
OscP5 oscP5;

//system's default port for receiveing osc messages
final int OSC_RECV_PORT = 14000;

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