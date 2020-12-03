import 'import.dart';

/// An route settings
/// arguments are discouraged and null should be handled
class ContentRoutePath {
  final ContentPath path;
  final Object arguments;

  ContentRoutePath(this.path, [this.arguments]);

  @override
  String toString() => '$path $arguments';
}
