import java.util.Iterator;

class RandomDecorator extends IterableDecorator {

  public RandomDecorator() {
    this(null);
  }

  RandomDecorator(IterableNode node) {
    super(node);
  }

  Iterator<BaseNode> iterator() {
    return new RandomIterator(getNode().getChildren());
  }

}
