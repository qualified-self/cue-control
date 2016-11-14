import java.io.Serializable;

public abstract class Condition implements Serializable {
  abstract boolean check(Blackboard agent);
}
