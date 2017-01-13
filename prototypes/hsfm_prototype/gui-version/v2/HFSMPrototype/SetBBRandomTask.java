/************************************************
************************************************
** implementing a task for setting the blackboard
************************************************
************************************************/

import controlP5.*;
import processing.core.PApplet;



class SetBBRandomTask extends SetBBTask {

  public SetBBRandomTask (PApplet p, ControlP5 cp5) {
    super(p, cp5, ("rand_" + (int)p.random(0, 100)), new Expression("math.random()"));
  }

  Group load_gui_elements(State s) {
    Group g = super.load_gui_elements(s);
    g.setLabel("Random variable");
    return g;
  }

}
