import 'dart:collection';

/// A First-In-First-Out (FIFO) queue implementation.
///
/// The [FiFoQueue] class represents a queue data structure where the first element added
/// is the first one to be removed. It has a specified [limit] which determines the maximum
/// number of elements that can be stored in the queue. If the queue exceeds the limit, the
/// oldest element is automatically removed to make space for the new element.
///
/// The [FiFoQueue] class is generic, allowing it to store elements of any type [T].
class FiFoQueue<T> {
  FiFoQueue(this.limit);
  static int total = 0;
  final int limit;

  final Queue<T> _queue = Queue<T>();

  int removed = 0;

  /// Adds a new element to the queue.
  /// If the queue has reached its [limit], the oldest element is removed before adding
  /// the new element.
  /// The [request] parameter represents the element to be added to the queue.
  void add(T request) {
    total++;
    if (_queue.length >= limit) {
      removed++;
      _queue.removeFirst();
    }
    _queue.add(request);
  }

  /// Returns a list of all elements currently in the queue.
  List<T> get value => _queue.toList();

  /// Retrieves the element at the specified [index] in the queue.
  /// If the [index] is less than the number of elements that have been removed from the queue,
  /// null is returned. Otherwise, the element at the specified [index] is returned.
  /// The [index] parameter represents the position of the element to retrieve.
  T? getItem(int index) {
    if (index < removed) {
      return null;
    }

    return _queue.elementAt(index - removed);
  }
}
