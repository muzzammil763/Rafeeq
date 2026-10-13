extension IterableExt<T> on Iterable<T> {
  Iterable<T> separatedBy(T separator) sync* {
    var iterator = this.iterator;

    if (isNotEmpty) {
      iterator.moveNext();
      yield iterator.current;
      while (iterator.moveNext()) {
        yield separator;
        yield iterator.current;
      }
    }
  }
}
