import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

/// A part is a field with an empty (not null) value
class ContentPathPart extends ContentPathField {
  /// Create a part with a name (and no value)
  ContentPathPart(String name) : super(name, '');

  /// Always valid
  @override
  bool isValid() => true;
}
