import java.io.Serializable;

/**
 * Defines a single task attached to the blackboard. Such tasks typically
 * aim to make values readily avaiable to the user through the use of the
 * blackboard. They should remain simple and should not perform output actions.
 */
public abstract class BlackboardTask implements Serializable {

  BlackboardTask() {
  }

	abstract void execute(Blackboard agent);
  void init(Blackboard agent) {}
  void build() {}
}
