import 'package:flutter/widgets.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_bloc.dart';

/// Base state with auto dispose
abstract class AutoDisposeBaseState<T extends StatefulWidget> extends State<T>
    with AutoDisposeMixin {
  @override
  @mustCallSuper
  void dispose() {
    audiDisposeAll();
    super.dispose();
  }
}
