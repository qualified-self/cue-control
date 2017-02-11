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

import javax.script.*;
import java.util.regex.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.io.Serializable;
import java.io.*;

//my osc variables
OscP5 oscP5;

//my controlP5 variable for gui
ControlP5 cp5;

//my minim variable
Minim       minim;


//system's default port for receiveing osc messages
final int OSC_RECV_PORT = 12345;

//calls all other utils
void setup_util() {
  setup_osc();
  setup_control_p5();
  setup_minim();
}

//function for setting up osc
void setup_osc () {
  // start oscP5, listening for incoming messages.
  oscP5 = new OscP5(this, OSC_RECV_PORT);
}

//function for setting up controlp5
void setup_control_p5 () {
  cp5 = new ControlP5(this);
}

//sets the minim up
void setup_minim() {
  minim = new Minim(this);
}

//rounds a float to two decimals for the gui
//retrieved from: http://stackoverflow.com/questions/8911356/whats-the-best-practice-to-round-a-float-to-2-decimals#8911683
public static BigDecimal round(float d, int decimalPlace) {
    BigDecimal bd = new BigDecimal(Float.toString(d));
    bd = bd.setScale(decimalPlace, BigDecimal.ROUND_HALF_UP);
    return bd;
}

/*
void setup_synapse () {
  NetAddress host = new NetAddress("localhost", 12346);
  OscMessage om;
  om = new OscMessage("righthand_trackjointpos");
  om.add(1);
  oscP5.send(om, host);
  om = new OscMessage("lefthand_trackjointpos");
  om.add(1);
  oscP5.send(om, host);
}

*/

/*
boolean is_kinect(String address) {

if (address.contains("righthand") ||
    address.contains("lefthand") ||
    address.contains("head") ||
    address.contains("torso"))
      return true;
  else
      return false;
}

boolean is_not_blacklisted(String address) {
  if (address.contains("bitalino") || is_kinect(address))
      return true;
  else
      return false;
}

void oscEvent(OscMessage msg) {
  if (debug) {
    System.out.println("### received an osc message.");
    System.out.println(" addrpattern: "+msg.addrPattern());
    System.out.println(" typetag: "+msg.typetag());
  }
  String addr = msg.addrPattern();
  if (is_not_blacklisted(addr))   {
    if (is_kinect(addr)) msg.setAddrPattern("/knct/"+addr);
    board.oscEvent(msg);
  }
}
*/

void oscEvent(OscMessage msg) {
  if (debug) {
    System.out.println("### received an osc message.");
    System.out.println(" addrpattern: "+msg.addrPattern());
    System.out.println(" typetag: "+msg.typetag());
  }

  board.oscEvent(msg);

}

int autosavetime = 2; //minutes
int timestamp;
File autosave_file;

void setup_autosave() {
  timestamp     = minute();
  autosave_file = new File(sketchPath() + "/data/patches/temp.txt");
  println(sketchPath());
}

void autosave() {
  int time_elapsed = abs(minute()-timestamp);

  if (time_elapsed > autosavetime) {
    serializer._saveAs(autosave_file);
    println("saving!");
    timestamp = minute();
  }
}