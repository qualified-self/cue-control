import java.util.Iterator;

class RandomizeDecorator extends IterableDecorator {

  public RandomizeDecorator() {
    this(null);
  }

  RandomizeDecorator(IterableNode node) {
    super(node);
  }

  Iterator<BaseNode> iterator() {
    return new RandomIterator(getNode().getEnabledChildren());
  }

}
