import 'package:flutter/widgets.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:test/test.dart';

class _MyNotifier<T> extends ValueNotifier<T> {
  _MyNotifier(super.value);
  var disposed = false;
  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class _Bloc extends AutoDisposeStateBaseBloc<void> {
  late final notifier = audiAddValueNotifier(_MyNotifier(0));
}

void main() {
  /// Make sure it compiles without flutter
  test('no_flutter', () {
    var bloc = _Bloc();
    var notifier = bloc.notifier as _MyNotifier;
    expect(notifier.disposed, isFalse);
    bloc.dispose();
    expect(notifier.disposed, isTrue);
  });
}
