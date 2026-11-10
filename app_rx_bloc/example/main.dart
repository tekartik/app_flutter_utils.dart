// A counter bloc provided to its page, and a name field whose controller and
// notifier are released by AutoDisposeBaseState.
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';

/// The counter state, pure Dart (testable with package:test).
class CounterBloc extends AutoDisposeStateBaseBloc<int> {
  var _count = 0;

  /// Starts at 0 (`state` has no value until the first `add`).
  CounterBloc() {
    add(_count);
  }

  /// Adds one, ignored once disposed.
  void increment() {
    if (!disposed) {
      add(++_count);
    }
  }
}

void main() {
  runApp(
    MaterialApp(
      home: BlocProvider<CounterBloc>(
        blocBuilder: () => CounterBloc(),
        child: const CounterPage(),
      ),
    ),
  );
}

/// Shows the count of the provided [CounterBloc].
class CounterPage extends StatelessWidget {
  /// Shows the count of the provided [CounterBloc].
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Rx bloc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ValueStreamBuilder<int>(
              stream: bloc.state,
              builder: (context, snapshot) => Text(
                'Count: ${snapshot.data}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const NameField(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: bloc.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A required name field.
class NameField extends StatefulWidget {
  /// A required name field.
  const NameField({super.key});

  @override
  State<NameField> createState() => _NameFieldState();
}

/// Its controller and notifier are disposed with the state.
class _NameFieldState extends AutoDisposeBaseState<NameField> {
  late final _controller = audiAddTextEditingController(
    TextEditingController(),
  );
  late final _valid = audiAddValueNotifier(ValueNotifier<bool>(false));

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _valid.value = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _valid,
      builder: (context, valid, _) => TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Name',
          errorText: valid ? null : 'Required',
        ),
      ),
    );
  }
}
