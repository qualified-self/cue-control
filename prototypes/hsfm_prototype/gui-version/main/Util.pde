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
final int OSC_RECV_PORT = 12001;

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


//checks if the user released the key minus
boolean user_pressed_minus () {
  boolean result = keyReleased && key=='-';
  //returns the result
  return result;
}
