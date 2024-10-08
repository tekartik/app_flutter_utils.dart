import 'package:tekartik_app_rx_bloc/auto_dispose_state_base_bloc.dart';
import 'package:test/test.dart';

class _Bloc extends AutoDisposeStateBaseBloc<void> {}

void main() {
  /// Make sure it compiles without flutter
  test('no_flutter', () {
    _Bloc();
  });
}
