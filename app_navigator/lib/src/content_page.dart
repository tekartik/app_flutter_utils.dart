// @sealed
// abstract class ContentPage extends Page {}

import 'import.dart';

typedef ContentPageBuilder = Page Function(ContentPathRouteSettings crp);
typedef ContentScreenBuilder = Widget Function(ContentPathRouteSettings rs);

abstract class ContentPageDef {
  factory ContentPageDef(
      {
      // should a build a default MaterialPage
      @deprecated ContentPageBuilder? builder,
      required ContentPath path,
      required ContentScreenBuilder? screenBuilder}) {
    return _ContentPageDef(
        builder: builder, path: path, screenBuilder: screenBuilder);
  }

  /// The path definition
  ContentPath? path;

  /// The builder, if used, name and arguments must match
  @deprecated
  ContentPageBuilder? builder;

  @override
  String toString() => 'def: $path';

  /// The screen builder
  ContentScreenBuilder? get screenBuilder;
}

class _ContentPageDef implements ContentPageDef {
  @override
  Page Function(ContentPathRouteSettings crp)? builder;

  @override
  ContentPath? path;

  @override
  final Widget Function(ContentPathRouteSettings crp)? screenBuilder;

  _ContentPageDef({this.builder, this.path, this.screenBuilder}) {
    // var name = path?.toPath();
    // devPrint('Building material page from $name');

    builder ??= (routePath) {
      var name = routePath.path!.toPath();
      return MaterialPage(
          name: name,
          arguments: routePath.arguments,
          key: ValueKey(name),
          child: Builder(
            builder: (_) {
              return screenBuilder!(routePath);
            },
          ));
    };
  }
  @override
  String toString() => 'def:$path';
}
