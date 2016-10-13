
/*****************************************************
 ** Default variables and methods for the Blackboard *
 *****************************************************
 ** jeraman.info, Oct. 11 2016 ***********************
 *****************************************************
 *****************************************************/

Blackboard bb;

void setup_blackboard() {
  bb = new Blackboard();
}

void draw_blackboard() {
  bb.draw();
}


/************************************************
 ** Class representing the blackboard ***********
 ************************************************
 ** jeraman.info, Oct. 11 2016 ******************
 ************************************************
 ************************************************/


//a blackboard item is a pair of a name (given by the user) and a value (given by the user or received via osc)
class Blackboard_Item {

  private String name;
  private Object value;

  //constructor
  Blackboard_Item (String name, Object value) {
    this.name = name;
    this.value = value;
  }

  //returns the name of this item
  String get_name() {
    return this.name;
  }

  //returns the type of this value
  String get_type() {
    return ((value.getClass()).getName());
  }

  //returns the value
  Object get_value() {
    return this.value;
  }

  //updates the value
  void update_value(Object new_value) {
    this.value = new_value;
  }

  void draw(int posx, int posy, int mywidth, int myheight) {
    int xoffset = mywidth+1;

    //header
    noStroke();
    fill(255, 50);
    rectMode(CENTER);
    rect(posx, posy, mywidth, myheight);
    rect(posx+xoffset, posy, mywidth, myheight);
    rect(posx+xoffset+xoffset, posy, mywidth, myheight);

    fill(200);
    textAlign(CENTER, CENTER);
    text(this.get_type(), posx, posy);
    text(name.toString(), posx+xoffset, posy);
    text(value.toString(), posx+xoffset+xoffset+5, posy);
  }
}

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//the actual blackboard class, defined as a vector of blackboard items 
class Blackboard {
  Vector<Blackboard_Item> items;
  int mywidth = 60;
  int myheight = 20;
  int x;
  int y;

  //contructor
  public Blackboard () {
    this.items = new Vector<Blackboard_Item>();
    this.x = width-(mywidth*3)-20;
    this.y = 20;
  }

  //adding an item into the blackboard
  void add_item(String name, Object value) {
    this.add_item(new Blackboard_Item(name, value));
  }

  //adding an item into the blackboard
  void add_item(Blackboard_Item bi) {
    //my returning variable
    Blackboard_Item item = contains(bi.get_name());

    if (item!=null)
      item.update_value(bi.get_value());
    else {
      items.addElement(bi);
      println("a new item " + bi.get_type() + " " + bi.get_name() + " = " + bi.get_value() + " was added to the blackboard");
    }
  }


  //looking for a specific item in the blackboard
  Blackboard_Item contains(String name) {

    //my returning variable
    Blackboard_Item item = null;

    //looks for a variable with the name received
    for (Blackboard_Item c : items) {
      if (c.get_name() == name) item = c;
    }

    //in case item is not found, this function returns null
    return item;
  }

  //removes an item from the blackboard
  void remove_item(String name) {
    //my returning variable
    Blackboard_Item item = contains(name);

    if (item!=null)
      items.remove(item);
    else
      println("Unable to remove item " + name + " from the blackboard.");
  }

  //updates the value of an item in the blackboard
  void update_item(String name, Object value) {
    //my returning variable
    Blackboard_Item item = contains(name);

    if (item!=null)
      item.update_value(value);
    else
      println("Unable to update item " + name + " from the blackboard.");
  }

  //updates the value of an item in the blackboard
  void update_item(Blackboard_Item bi) {
    //my returning variable
    Blackboard_Item item = contains(bi.name);

    if (item!=null)
      item.update_value(bi.get_value());
    else
      println("Unable to update item " + bi.get_name() + " from the blackboard.");
  }
  
  Object get_value_by_name (String name) {
    //my returning variable
    Blackboard_Item item = contains(name);

    if (item!=null)
      return item.get_value();
    else
      return null;
  }

  /////////////////
  // gui methods
  void move_gui (int newx, int newy) {
    this.x = newx;
    this.y = newy;
  }

  //draws both the header and the items
  void draw() {
    draw_header_gui ();
    draw_bb_items ();
  }

  //draws the header
  void draw_header_gui () {
    noStroke();
    fill(255, 200);
    rectMode(CENTER);
    rect(x+mywidth, y, (mywidth*3), myheight);
    rectMode(CORNERS);

    fill(50);
    textAlign(CENTER, CENTER);
    text("BLACKBOARD", x+mywidth, y);
  }

  //draws the items
  void draw_bb_items () {
    draw_header_gui();

    for (int i = 0; i < items.size(); i++)
      items.get(i).draw(x, y+(myheight*(i+1))+i+1, mywidth, myheight);
  }
}