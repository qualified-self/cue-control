/************************************************
 ** Class representing a conection between two states in the HFSM
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

import java.io.Serializable;
import processing.core.PApplet;
import javax.script.*;
import controlP5.*;

public class Connection implements Serializable {
  private State      next_state;
  private Expression expression;
  private int        priority;
  private State      parent;

  //GUI ELEMENTS
  int background;
  int foreground;
  transient PApplet p;
  transient ControlP5 cp5;

  //constructor for an empty transition
  public Connection (PApplet p, ControlP5 cp5, State par, State ns, int priority) {
    this(p, cp5, par, ns, new Expression("true"), priority);
  }

  //constructor for a more complex transition
  public Connection (PApplet p, ControlP5 cp5, State parent, State ns, Expression expression, int priority) {
    this.p = p;
    this.cp5 = cp5;
    this.next_state = ns;
    this.priority   = priority;
    this.expression = expression;
    this.parent     = parent;
    //@TODO PROBLEM TAKING TIME TO LOAD IS IN THE FOLLOWING METHOD!!!
    init_gui_items();
  }

  void build(PApplet p, ControlP5 cp5) {
    this.p = p;
    this.cp5 = cp5;
    this.expression.build(p);
    init_gui_items();
  }

  //function that tries to evaluates the value (if necessary) and returns the real value
  boolean is_condition_satisfied () {
    Object ret = false;

    try {
      ret = expression.eval(HFSMPrototype.instance().board());
    }
    catch (ScriptException e) {
      System.out.println("Problems in processing certain transition condition. Expr: " + expression.toString() + " next state: " + next_state.toString());
      ret = false;
    }

    if (ret instanceof Boolean)
      return (boolean)ret;
    else {
      System.out.println("Expr: " + expression.toString() + " result is not a boolean. it is a " + ret.toString());
      return false;
    }
  }

  //updates an expression
  void update_expression(Expression exp) {
    this.expression = exp;
  }

  //updates an expression
  void update_priority(int p) {
    this.priority = p;
  }

  //returns the next state
  State get_next_state() {
    return next_state;
  }

  //gets a condition
  Expression get_expression() {
    return this.expression;
  }

  int get_priority() {
    return this.priority;
  }

  /*******************************************
   ** GUI FUNCTIONS ***************************
   ********************************************/
   //@TODO PROBLEM TAKING TIME TO LOAD IS IN THE FOLLOWING METHOD!!!
  int w=20;
  void init_gui_items() {
    String gui_name = parent.get_name() + "_" + next_state.get_name();

    ControlP5 cp5  = get_controlP5_gui();

    //p.println(cp5);

    background = p.color(0, 0, 0, 50);
    foreground = p.color(0, 116, 217, 200);
    int white  = p.color(255, 255);

     DropdownList d = cp5.addDropdownList(gui_name+"/priority")
       .setWidth(w)
       .setItemHeight(20)
       .setBarHeight(15)
       .setBackgroundColor(background)
       .setColorBackground(background)
       .setOpen(false)
       .setValue(this.priority)
       .setLabel(this.priority+"")
       .onChange(generate_callback_dropdown())
       ;

     init_dropdown_list(parent.get_number_of_connections());

     String text = this.expression.toString();

     Textfield t = cp5.addTextfield(gui_name+"/condition")
       .setText(text)
       .setColorValue(white)
       .setColorBackground(background)
       .setColorForeground(background)
       .setWidth(get_label_width() - w)
       .setHeight(15)
       .setFocus(false)
       .setAutoClear(false)
       .setLabel("")

       ;

      //if this is a transition to self, impossible to change the expression. the goal is to avoid deadends
      if (parent==next_state) {
        d.setUserInteraction(false);
        d.lock();
        t.setUserInteraction(false);
        t.setText("anything else");
        t.setWidth((int)((p.textWidth("anything else")*1.3)));
        t.lock();
      //otherwise, adds user interactivity
      } else  {
        t.onEnter(generate_callback_textfield_enter());
        t.onLeave(generate_callback_textfield_leave());
        t.onReleaseOutside(generate_callback_textfield_released_outside());
        t.onChange(generate_callback_textfield_change());
      }

     }

  void remove_gui_items() {
    //ControlP5 cp5 = get_controlP5_gui();
    String gui_name = parent.get_name() + "_" + next_state.get_name();
    cp5.remove(gui_name+"/priority");
    cp5.remove(gui_name+"/condition");
    //println("trying to remove");
  }

  void reload_gui_items() {
    remove_gui_items();
    init_gui_items();
  }

  int get_label_width() {
    if (parent==next_state)
      return (int)(w+(p.textWidth("anything else")*1.3));
    else
      return (int)(w+(p.textWidth(this.expression.toString())*1.3));
  }

  ControlP5 get_controlP5_gui() {
    //String gui_name = parent.get_name() + "_" + next_state.get_name();
    return HFSMPrototype.instance().cp5();
  }

  DropdownList get_dropdown_gui () {
    String gui_name = parent.get_name() + "_" + next_state.get_name();
    return (DropdownList)get_controlP5_gui().getController(gui_name+ "/priority");
  }

  Textfield get_textfield_gui () {
    String gui_name = parent.get_name() + "_" + next_state.get_name();
    return (Textfield)get_controlP5_gui().getController(gui_name+ "/condition");
  }


   void set_gui_position (int newx, int newy) {

    DropdownList d = get_dropdown_gui();
    Textfield    t = get_textfield_gui();

     // if any of the gui elements is null, does nothing
     if (d ==null || t==null) return;

     d.setPosition(newx, newy);
     t.setPosition(newx+w+5, newy);
   }


   void init_dropdown_list(int n) {
     DropdownList d = get_dropdown_gui();
     for (int i=1; i<=n; i++) {
       d.addItem(i+"", i);
     }
   }

   boolean is_mouse_over () {
     DropdownList d = get_dropdown_gui();
     Textfield    t = get_textfield_gui();
     return t.isMouseOver() || d.isMouseOver();
   }

   boolean should_be_removed() {
     if (HFSMPrototype.instance().user_pressed_minus() && is_mouse_over())
        return true;
     else
        return false;
   }

   CallbackListener generate_callback_dropdown() {
     return new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         int newPriority = 1+(int)theEvent.getController().getValue();
         //println("new value on the dropdown is " + newPriority);
         parent.update_priority(priority, newPriority);
       }
     };
   }

   CallbackListener generate_callback_textfield_enter() {
     return new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         Textfield    t = get_textfield_gui();
         t.setColorBackground(foreground);
         t.setColorForeground(foreground);
       }
     };
   }

   CallbackListener generate_callback_textfield_leave() {
     return new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         Textfield    t = get_textfield_gui();
         t.setColorBackground(background);
         t.setColorForeground(background);
       }
     };
   }

   CallbackListener generate_callback_textfield_change() {
     return new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         //@TODO implement the update
         Textfield    t = get_textfield_gui();
         Expression exp = new Expression(t.getText());
         update_expression(exp);
         reload_gui_items();
       }
     };
   }

   CallbackListener generate_callback_textfield_released_outside() {
     return new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         //@TODO implement the text to its old value (not updated)
         Textfield    t = get_textfield_gui();
         String newText = theEvent.getController().getValueLabel().getText();
         String oldText = get_expression().toString();
         if (!oldText.equals(newText))
            t.setText(oldText);
       }
     };
   }

}
