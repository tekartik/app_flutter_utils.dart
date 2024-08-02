import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class BusyActionResult<T> {
  final T? result;
  // true if result or error is filled, not done if busy
  final bool busy;
  final Object? error;

  BusyActionResult({
    this.busy = false,
    this.result,
    this.error,
  });
}

mixin BusyScreenStateMixin<T extends StatefulWidget> on State<T> {
  final _busySubject = BehaviorSubject<bool>.seeded(false);
  ValueStream<bool> get busyStream => _busySubject.stream;

  bool get busy => _busySubject.value == true;

  /// Action if not busy
  Future<BusyActionResult<R>> busyAction<R>(Future<R> Function() action) async {
    if (_busySubject.value == true) {
      return BusyActionResult(busy: true);
    }
    _busySubject.add(true);
    try {
      var result = await action();
      return BusyActionResult(result: result, busy: false);
    } catch (e) {
      return BusyActionResult(error: e, busy: false);
    } finally {
      if (mounted) {
        _busySubject.add(false);
      }
    }
  }

  void busyDispose() {
    _busySubject.close();
  }
}
