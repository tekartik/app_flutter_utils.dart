import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';

class BusyActionResult<T> {
  final T? result;
  // true if result or error is filled, not done if busy
  final bool busy;
  final Object? error;
  final StackTrace? errorStackTrace;

  BusyActionResult({
    this.busy = false,
    this.result,
    this.error,
    this.errorStackTrace,
  });
}

/// Busy screen state
abstract class BusyScreenState<T extends StatefulWidget> implements State<T> {
  BehaviorSubject<bool> get _busySubject;
}

/// Auto disposed busy screen state mixin
mixin AutoDisposedBusyScreenStateMixin<T extends StatefulWidget> on State<T>
    implements BusyScreenState<T>, AutoDispose {
  @override
  late final _busySubject = audiAddBehaviorSubject(
    BehaviorSubject<bool>.seeded(false),
  );
}

/// Busy screen state mixin
mixin BusyScreenStateMixin<T extends StatefulWidget> on State<T>
    implements BusyScreenState<T> {
  @override
  final _busySubject = BehaviorSubject<bool>.seeded(false);
}

/// Busy screen state mixin extension
extension BusyScreenStateMixinExtension<T extends StatefulWidget>
    on BusyScreenState<T> {
  Sink<bool> get busySink => _busySubject.sink;
  ValueStream<bool> get busyStream => _busySubject.stream;

  bool get busy => _busySubject.value;

  /// Action if not busy
  Future<BusyActionResult<R>> busyAction<R>(Future<R> Function() action) async {
    if (_busySubject.value) {
      return BusyActionResult(busy: true);
    }
    _busySubject.add(true);
    try {
      var result = await action();
      return BusyActionResult(result: result, busy: false);
    } catch (e, st) {
      return BusyActionResult(error: e, errorStackTrace: st, busy: false);
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
