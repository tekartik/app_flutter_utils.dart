// A counter page whose bloc is created by BlocProvider and disposed with it.
import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';

/// The counter bloc: a stream of values.
class CounterBloc extends BaseBloc {
  final _count = StreamController<int>.broadcast();
  var _value = 0;

  /// The values, after each [increment].
  Stream<int> get count => _count.stream;

  /// Add one.
  void increment() {
    if (!disposed) {
      _count.add(++_value);
    }
  }

  @override
  void dispose() {
    _count.close();
    super.dispose();
  }
}

/// The page, owner of the bloc.
class CounterPage extends StatelessWidget {
  /// The page, owner of the bloc.
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      blocBuilder: () => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter')),
        body: const Center(child: CounterText()),
        // Builder: a context below the provider.
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => BlocProvider.of<CounterBloc>(context).increment(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

/// Shows the count.
class CounterText extends StatelessWidget {
  /// Shows the count.
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<CounterBloc>(context);
    return StreamBuilder<int>(
      stream: bloc.count,
      initialData: 0,
      builder: (context, snapshot) => Text('${snapshot.data}'),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: CounterPage()));
}
