import 'import.dart';

/// Content path route settings
class ContentPathRouteSettings {
  /// The path
  final ContentPath path;

  /// The arguments
  final Object? arguments;

  /// Create a new route settings
  ContentPathRouteSettings(this.path, [this.arguments]);

  /// From raw representation.
  static ContentPathRouteSettings fromRaw(RouteSettings settings) {
    return ContentPathRouteSettings(
      ContentPath.fromString(settings.name!),
      settings.arguments,
    );
  }

  @override
  String toString() => 'cp: $path${(arguments != null) ? ' $arguments' : ''}';
}

/// Helper for push
extension ContentPathRouteSettingsExt on ContentPathRouteSettings {
  /// To raw representation.
  RouteSettings toRaw() =>
      RouteSettings(name: path.toPathString(), arguments: arguments);
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
