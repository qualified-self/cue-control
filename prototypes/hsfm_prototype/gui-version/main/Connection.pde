/************************************************
 ** Class representing a conection between two states in the HFSM
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

public class Connection {
  private State      next_state;
  private Expression expression;
  private int        priority;
  private State      parent;

  //GUI ELEMENTS
  DropdownList d;
  Textfield    t;
  //color background = color(50, 50, 50, 200);
  color background = color(0, 0, 0, 50);
  color foreground = color(0, 116, 217, 200);
  //private ConnectionLabel gui_label;

  //constructor for an empty transition
  public Connection (State p, State ns, int priority) {
    this(p, ns, new Expression("true"), priority);
  }

  //constructor for a more complex transition
  public Connection (State parent, State ns, Expression expression, int priority) {
    this.next_state = ns;
    this.priority   = priority;
    this.expression = expression;
    this.parent     = parent;
    init_gui_items();
  }

  //function that tries to evaluates the value (if necessary) and returns the real value
  boolean is_condition_satisfied () {
    Object ret = false;

    try {
      ret = expression.eval(bb);
    }
    catch (ScriptException e) {
      println("Problems in processing certain transition condition. Expr: " + expression.toString() + " next state: " + next_state.toString());
      ret = false;
    }

    if (ret instanceof Boolean)
      return (boolean)ret;
    else {
      println("Expr: " + expression.toString() + " result is not a boolean. it is a " + ret.toString());
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

  /*******************************************
   ** GUI FUNCTIONS ***************************
   ********************************************/
  int w=20;
  void init_gui_items() {
    String gui_name = parent.get_name() + "_" + next_state.get_name();

     d = cp5.addDropdownList(gui_name+"/priority")
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

     init_dropdown_list(parent.connections.size());

     String text = this.expression.toString();

     t = cp5.addTextfield(gui_name+"/condition")
       .setText(text)
       .setColorValue(color(255, 255))
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
        t.setWidth((int)((textWidth("anything else")*1.3)));
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
      return (int)(w+(textWidth("anything else")*1.3));
    else
      return (int)(w+(textWidth(this.expression.toString())*1.3));
  }

   void set_gui_position (int newx, int newy) {
     // if any of the gui elements is null, does nothing
     if (d ==null || t==null) return;

     d.setPosition(newx, newy);
     t.setPosition(newx+w+5, newy);
   }


   void init_dropdown_list(int n) {
     for (int i=1; i<=n; i++) {
       d.addItem(i+"", i);
     }
   }

   /*
   void add_item_to_dropdown (int i ) {
     d.addItem(i+"", i);
   }

   void remove_item_to_dropdown (int i ) {
     d.removeItem(i);
   }
   */

   boolean is_mouse_over () {
     return t.isMouseOver() || d.isMouseOver();
   }

   boolean should_be_removed() {
     if (user_pressed_minus() && is_mouse_over())
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
         //else, executes the callback
         t.setColorBackground(foreground);
         t.setColorForeground(foreground);
       }
     };
   }

   CallbackListener generate_callback_textfield_leave() {
     return new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         t.setColorBackground(background);
         t.setColorForeground(background);
       }
     };
   }

   CallbackListener generate_callback_textfield_change() {
     return new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
         //@TODO implement the update
         //println("next test is" + t.getText());
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
         String newText = theEvent.getController().getValueLabel().getText();
         String oldText = get_expression().toString();
         if (!oldText.equals(newText))
            t.setText(oldText);
       }
     };
   }

}
