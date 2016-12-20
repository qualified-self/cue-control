import java.util.*;

public class RandomIterator<T> implements Iterator<T> {

    private Iterator<Integer> indicies;

    List<T> delegate;

    public RandomIterator(List<T> delegate) {
        Random r = new Random();
        this.delegate = delegate;
        Set<Integer> indexSet = new LinkedHashSet<>();
        while(indexSet.size() != delegate.size())
            indexSet.add(r.nextInt(delegate.size()));

        System.out.println(indexSet);
        indicies = indexSet.iterator();
    }

    public boolean hasNext() {
        return indicies.hasNext();
    }

    public T next() {
        return delegate.get(indicies.next());
    }
}
