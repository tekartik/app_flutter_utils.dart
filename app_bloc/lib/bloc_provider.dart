import 'package:flutter/widgets.dart';
import 'package:tekartik_app_bloc/base_bloc.dart';

export 'package:tekartik_app_bloc/base_bloc.dart';

/// Creates a [BaseBloc] of type [T] once when mounted ([blocBuilder]), makes
/// it available to the widgets below ([of]) and disposes it when removed
/// from the tree.
class BlocProvider<T extends BaseBloc> extends StatefulWidget {
  /// The widgets that can find the bloc.
  final Widget child;

  /// Creates the bloc, called once (in `initState`).
  final T Function() blocBuilder;

  /// Provides the bloc created by [blocBuilder] to [child].
  const BlocProvider({
    super.key,
    required this.blocBuilder,
    required this.child,
  });

  @override
  State<BlocProvider> createState() => _BlocProviderState<T>();

  /// The bloc of the closest `BlocProvider<T>` above [context] (exact type
  /// [T]). It registers no dependency: nothing rebuilds when the bloc
  /// changes. Throws a `TypeError` when there is none.
  static T of<T extends BaseBloc>(BuildContext context) {
    var provider =
        context
                .getElementForInheritedWidgetOfExactType<
                  _BlocProviderInherited<T>
                >()
                ?.widget
            as _BlocProviderInherited<T>;

    return provider.bloc;
  }
}

class _BlocProviderState<T extends BaseBloc> extends State<BlocProvider> {
  late T _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.blocBuilder() as T;
  }

  @override
  Widget build(BuildContext context) {
    return _BlocProviderInherited<T>(bloc: _bloc, child: widget.child);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  const _BlocProviderInherited({
    super.key,
    required super.child,
    required this.bloc,
  });

  final T bloc;

  @override
  bool updateShouldNotify(_BlocProviderInherited oldWidget) => false;
}
