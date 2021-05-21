import 'import.dart';

/// An route settings
/// arguments are discouraged and null should be handled
@deprecated
class ContentRoutePath extends ContentPathRouteSettings {
  ContentRoutePath(ContentPath path, [Object? arguments])
      : super(path, arguments);
}

class ContentPathRouteSettings {
  final ContentPath path;
  final Object? arguments;

  ContentPathRouteSettings(this.path, [this.arguments]);

  @override
  String toString() => '$path $arguments';
}

/// Helper for push
extension ContentPathRouteExt on ContentPath {
  /// Build a new route settings
  ContentPathRouteSettings routeSettings([Object? arguments]) {
    // Perform validation (here we are likely in a push new route scenario)
    for (var part in fields) {
      assert(part.value != null, 'invalid path $this');
    }
    return ContentPathRouteSettings(this, arguments);
  }
}
