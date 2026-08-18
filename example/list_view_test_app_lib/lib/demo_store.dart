import 'dart:async';
import 'dart:math';

/// In memory data source mimicking a database: paged queries with a
/// simulated latency, and a change notification allowing pages to be watched.
///
/// Counts the queries it runs, which is what makes the cost of a watched list
/// visible: on every change, each watched page re-runs its query.
class DemoStore {
  /// Creates [count] items.
  DemoStore({
    int count = 100000,
    this.latency = const Duration(milliseconds: 100),
  }) : _items = List.generate(count, (i) => 'Item ${i + 1}');

  /// Simulated query duration.
  final Duration latency;

  final List<String> _items;
  final _onChange = StreamController<void>.broadcast();
  final _random = Random();
  Timer? _writerTimer;

  /// Number of page queries run so far, reset by [resetQueryCount].
  var queryCount = 0;

  /// Current number of items.
  int get length => _items.length;

  /// True while [toggleWriter] is running.
  bool get isWriting => _writerTimer != null;

  /// Reset [queryCount].
  void resetQueryCount() => queryCount = 0;

  /// One page of items.
  Future<List<String>> getItems(int offset, int limit) async {
    queryCount++;
    await _wait();
    return _items.skip(offset).take(limit).toList();
  }

  /// Total count.
  Future<int> getCount() async {
    await _wait();
    return _items.length;
  }

  /// Page watched, re-queried on every change.
  Stream<List<String>> watchItems(int offset, int limit) =>
      _watch(() => getItems(offset, limit));

  /// Count watched, re-counted on every change.
  Stream<int> watchCount() => _watch(getCount);

  Future<void> _wait() =>
      latency > Duration.zero ? Future<void>.delayed(latency) : Future.value();

  Stream<T> _watch<T>(Future<T> Function() query) {
    late StreamController<T> controller;
    StreamSubscription<void>? subscription;
    void add() {
      query().then((value) {
        if (!controller.isClosed) {
          controller.add(value);
        }
      });
    }

    controller = StreamController<T>(
      onListen: () {
        add();
        subscription = _onChange.stream.listen((_) => add());
      },
      onCancel: () async {
        await subscription?.cancel();
        subscription = null;
      },
    );
    return controller.stream;
  }

  /// Modify one random item and notify the watchers.
  void writeOne() {
    if (_items.isEmpty) {
      return;
    }
    var index = _random.nextInt(_items.length);
    var item = _items[index];
    var separator = item.lastIndexOf(' * ');
    var text = separator == -1 ? item : item.substring(0, separator);
    _items[index] = '$text * ${DateTime.now().millisecondsSinceEpoch % 100000}';
    _notify();
  }

  /// Start/stop a background writer, mimicking an app writing while the user
  /// scrolls.
  void toggleWriter() {
    if (_writerTimer != null) {
      _writerTimer?.cancel();
      _writerTimer = null;
      return;
    }
    _writerTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => writeOne(),
    );
  }

  /// Remove the last item and notify the watchers.
  void removeLast() {
    if (_items.isEmpty) {
      return;
    }
    _items.removeLast();
    _notify();
  }

  void _notify() {
    if (!_onChange.isClosed) {
      _onChange.add(null);
    }
  }

  /// Close, must be called when done.
  void dispose() {
    _writerTimer?.cancel();
    _writerTimer = null;
    unawaited(_onChange.close());
  }
}
