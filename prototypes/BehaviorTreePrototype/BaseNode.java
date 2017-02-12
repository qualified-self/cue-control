import java.io.*;

public abstract class BaseNode implements Serializable
{
  transient State state = State.SUCCESS;

  String description;

  Decorator decorator;

  transient boolean needsInit;

  CompositeNode parent;

  boolean isEnabled;

  // Saved string description of the node (for later retrieval).
  private String savedDeclaration;

  BaseNode()
  {
    this(null);
  }

  BaseNode(String description)
  {
    this.parent = null;
    this.description = description;
    isEnabled = true;
    state = State.UNDEFINED;
  }

  void build() {
    state = State.UNDEFINED;
    needsInit = true;
  }

  void saveDeclaration(String declaration) {
    savedDeclaration = declaration;
  }

  String loadDeclaration() { return savedDeclaration; }

  BaseNode setDecorator(Decorator decorator) {
    decorator.setNode(this);
    this.decorator = decorator;
    needsInit = true;
    return this;
  }

  BaseNode removeDecorator() {
		if (hasDecorator()) {
	    decorator.setNode(null);
	    this.decorator = null;
	    needsInit = true;
		}
    return this;
  }

  boolean hasDecorator() { return decorator != null; }

  Decorator getDecorator() { return decorator; }

  void removeParent() {
    parent = null;
  }

  BaseNode setParent(CompositeNode parent) {
    if (hasParent()) {
      Console.instance().warning("Cannot set parent: already has one. Remove it first.");
    }
    else
      this.parent = parent;
    return this;
  }

  boolean hasParent() { return parent != null; }

  CompositeNode getParent() { return parent; }

  boolean isEnabled() { return isEnabled; }
  void setEnabled(boolean isEnabled) {
    this.isEnabled = isEnabled;
  }
  void toggleEnabled() {
    isEnabled = !isEnabled;
  }

  void init(Blackboard agent) {
    needsInit = false;

    // FIXME: In fact, init of node should not necessarily trigger an init of
    // its decorator. See ChronoDecorator for example.
    if (hasDecorator())
      decorator.init(agent);
    else
      doInit(agent);

    // Reset previous state.
    state = State.UNDEFINED;
  }

  State execute(Blackboard agent)
  {
//    BehaviorTreePrototype.instance().println("exec called on class " + type());
    if (needsInit) {
      init(agent);
    }

    if (!isEnabled()) {
      Console.instance().error("A disabled node has been executed: this should not be happening.");
      return state;
    }

    if (hasDecorator())
      state = decorator.execute(agent);
    else
      state = doExecute(agent);

    if (state != State.RUNNING)
      needsInit = true;

    return state;
  }

  State getState() { return state; }
  String getDescription() {
    String desc = (description == null ? getDefaultDescription() : description);
    String dynDesc = getDynamicDescription();
    if (dynDesc != null)
      desc += " [" + dynDesc + "]";
    return desc;
  }

  String getDefaultDescription() { return ""; }

  String getDynamicDescription() { return null; }

  abstract State doExecute(Blackboard agent);
  abstract void doInit(Blackboard agent);

  String baseName() {
    String basename = getClass().getSimpleName();
    return basename.substring(0, basename.length() - "Node".length());
  }

  String type() {
    return Utils.camelCaseToDash(baseName());
  }

  void scheduleInit() { needsInit = true; }

  void setPlayState(boolean playing) {
    if (hasDecorator())
      getDecorator().setPlayState(playing);
  }

  void play()  { setPlayState(true); }
  void pause() { setPlayState(false); }

  public BaseNode clone() {
    try {
      ByteArrayOutputStream bos = new ByteArrayOutputStream();
      ObjectOutputStream oos = new ObjectOutputStream(bos);
      oos.writeObject(this);
      oos.flush();
      oos.close();
      bos.close();
      byte[] byteData = bos.toByteArray();

      ByteArrayInputStream bais = new ByteArrayInputStream(byteData);
      return (BaseNode) new ObjectInputStream(bais).readObject();
    } catch (Exception e) {
      Console.instance().error("Could not copy node.");
      return null;
    }
  }
}
