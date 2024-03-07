import 'dart:collection';

class FiFoQueue<T> {
  FiFoQueue(this.limit);
  static int total = 0;
  final int limit;

  final Queue<T> _queue = Queue<T>();

  int removed = 0;

  void add(T request) {
    total++;
    if (_queue.length >= limit) {
      removed++;
      _queue.removeFirst();
    }
    _queue.add(request);
  }

  List<T> get value => _queue.toList();

  T? getItem(int index) {
    if (index < removed) {
      return null;
    }

    return _queue.elementAt(index - removed);
  }
}
