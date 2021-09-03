import 'package:flutter/widgets.dart';
import 'package:tekartik_app_bloc/base_bloc.dart';

export 'package:tekartik_app_bloc/base_bloc.dart';

class BlocProvider<T extends BaseBloc> extends StatefulWidget {
  final Widget child;
  final T Function() blocBuilder;

  const BlocProvider({Key? key, required this.blocBuilder, required this.child})
      : super(key: key);

  @override
  _BlocProviderState createState() => _BlocProviderState<T>();

  static T of<T extends BaseBloc>(BuildContext context) {
    var provider = context
        .getElementForInheritedWidgetOfExactType<_BlocProviderInherited<T>>()
        ?.widget as _BlocProviderInherited<T>;

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
    return _BlocProviderInherited<T>(
      bloc: _bloc,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  const _BlocProviderInherited({
    Key? key,
    required Widget child,
    required this.bloc,
  }) : super(key: key, child: child);

  final T bloc;

  @override
  bool updateShouldNotify(_BlocProviderInherited oldWidget) => false;
}
