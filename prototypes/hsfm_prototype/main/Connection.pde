/************************************************
 ** Class representing a conection between two states in the HFSM
 ************************************************
 ** jeraman.info, Sep. 30 2016 ******************
 ************************************************
 ************************************************/

public class Connection {
  private State next_state;
  private Input condition;
  
  public Connection (State ns, Input c) {
    this.next_state = ns;
    this.condition = c;
  }
  
  boolean is_condition_satisfied (Input c) {
    return (c==this.condition);
  }
  
  State get_next_state() {
    return next_state;
  }
}