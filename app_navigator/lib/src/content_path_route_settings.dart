import 'import.dart';

/// An route settings
/// arguments are discouraged and null should be handled
@Deprecated('Not supported anymore')
class ContentRoutePath extends ContentPathRouteSettings {
  ContentRoutePath(ContentPath path, [Object? arguments])
      : super(path, arguments);
}

class ContentPathRouteSettings {
  final ContentPath path;
  final Object? arguments;

  ContentPathRouteSettings(this.path, [this.arguments]);

  /// From raw representation.
  static ContentPathRouteSettings fromRaw(RouteSettings settings) {
    return ContentPathRouteSettings(
      ContentPath.fromString(settings.name!),
      settings.arguments,
    );
  }

  @override
  String toString() => '$path $arguments';
}

extension ContentPathRouteSettingsExt on ContentPathRouteSettings {
  /// To raw representation.
  RouteSettings toRaw() => RouteSettings(
        name: path.toPathString(),
        arguments: arguments,
      );
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
