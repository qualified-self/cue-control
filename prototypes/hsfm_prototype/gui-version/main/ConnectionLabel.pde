/************************************************
 ** GUI class for the connections info *********
 ************************************************
 ** jeraman.info, Nov. 29 2016 ******************
 ************************************************
 ************************************************/

class ConnectionLabel {

  DropdownList d;
  Textfield    t;
  color background = color(120);
  color foreground = color(0, 116, 217);

  public ConnectionLabel (int x, int y) {
    //this.x = x;
    //this.y = y;
    init_gui_items(x,y);
  }

  void init_gui_items(int x, int y) {
    d = cp5.addDropdownList("myList-d1")
      .setWidth(25)
      .setItemHeight(20)
      .setBarHeight(15)
      .setBackgroundColor(background)
      .setColorBackground(color(120))
      .setOpen(false)
      .setValue(10)
      .setLabel("10")
      .onChange(generate_callback_dropdown())
      ;

    init_dropdown_list(d);

    t = cp5.addTextfield("name")
      .setText("name")
      .setColorValue(color(255, 255))
      .setColorBackground(background)
      .setColorForeground(background)
      .setWidth((int)(textWidth("name")*0.8))
      .setHeight(15)
      .setFocus(false)
      .setAutoClear(false)
      .setLabel("")
      .onEnter(generate_callback_textfield_enter())
      .onLeave(generate_callback_textfield_leave())
      .onReleaseOutside(generate_callback_textfield_released_outside())
      .onChange(generate_callback_textfield_change())
      ;

     set_gui_position(x, y);
  }

  void set_gui_position (int newx, int newy) {
    d.setPosition(newx, newy);
    t.setPosition(newx+30, newy);
  }

  void init_dropdown_list(DropdownList d) {
    for (int i=0; i<40; i++) {
      d.addItem(i+"", i);
    }
  }

  CallbackListener generate_callback_dropdown() {
    return new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        println("new value on the dropdown is " + theEvent.getController().getValue());
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
        println("next test is" + t.getText());
      }
    };
  }

  CallbackListener generate_callback_textfield_released_outside() {
    return new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        //@TODO implement the text to its old value (not updated)
        println("old test is" + t.getText());
      }
    };
  }
}
