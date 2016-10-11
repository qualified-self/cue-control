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
    return ((value.getClass()).toString());
  }
  
  //returns the value
  Object get_value() {
    return this.value;
  }
  
  //updates the value
  void update_value(Object new_value) {
    this.value = new_value;
  }
}

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//the actual blackboard class, defined as a vector of blackboard items 
class Blackboard {
  Vector<Blackboard_Item> items;
  
  //contructor
  public Blackboard () {
    this.items = new Vector<Blackboard_Item>();
  }
  
  //adding an item into the blackboard
  void add_item(String name, Object value) {
    items.addElement(new Blackboard_Item(name, value));
    println("a new item " + name + " with value " + value + " was added to the blackboard");
  }
  
  //looking for a specific item in the blackboard
  Blackboard_Item contains(String name) {
    
    //my returning variable
    Blackboard_Item item = null;
    
    //looks for a variable with the name received
    for (Blackboard_Item c : items) {
      if (c.name == name) item = c;
    }
    
    //in case item is not found, this function returns null
    return item;
  }
  
  void remove_item(String name) {
    //my returning variable
    Blackboard_Item item = contains(name);
    
    if (item!=null)
      items.remove(item);
    else
      println("Unable to remove item " + name + " from the blackboard.");
  }
  
  void update_item(String name, Object value) {
    //my returning variable
    Blackboard_Item item = contains(name);
    
    if (item!=null)
      item.update_value(value);
    else
      println("Unable to update item " + name + " from the blackboard.");
  }
  
  
}