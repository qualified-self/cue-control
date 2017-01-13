/************************************************
************************************************
** implementing a task for setting the blackboard
************************************************
************************************************/

import controlP5.*;
import processing.core.PApplet;


class SetBBRampTask extends SetBBTask {
  Object period;
  Object amplitude;
  Blackboard board;

  public SetBBRampTask (PApplet p, ControlP5 cp5) {
    super(p, cp5, ("rand_" + p.random(0, 100)), new Expression("math.random()"));
  }

  Group load_gui_elements(State s) {
    Group g = super.load_gui_elements(s);
    g.setLabel("Ramp variable");
    return g;
  }

}
