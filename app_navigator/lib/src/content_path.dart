import 'package:path/path.dart' as p;

import 'import.dart';

/// Content path base class.
abstract class ContentPathBase with PathMixin {}

/// Like firestore type/id/type/id in url format for url reference.
///
/// Warning toString() should not be used to convert to a path, use
/// toStringPath() instead.
///
/// root is / (or empty string)
abstract class ContentPath {
  /// The separator used in the path
  static var separator = p.url.separator;

  /// Field accessor
  List<ContentPathField> get fields;

  /// From a coll1/id1/coll2/id2
  factory ContentPath.fromString(String path) {
    return _PathFromPath(path);
  }

  /// Direct constructor
  factory ContentPath(List<ContentPathField> fields) => _ContentPath(fields);

  /// Copy from a path
  void fromPath(ContentPath path);

  /// to a path as string path.
  String toPathString();

  /// A map representing the data, but likely unorderd.
  Map<String?, String?> toStringMap();

  /// If both path matches /one/1/two/2 matching /one/34/two/27
  bool matchesPath(ContentPath? path);

  /// if it starts with a content path (i.e. is a child of another content path)
  bool startsWith(ContentPath path);

  /// Get a field.
  ContentPathField? field(String? name);
}

/// Extension to help with content path
extension ContentPathExt on ContentPath {
  /// Helper to match a string path directly
  bool matchesString(String path) {
    return matchesPath(ContentPath.fromString(path));
  }

  /// Helper to match a string path directly
  @Deprecated('Use toPathString instead')
  String toPath() => toPathString();

  /// Check if the path is valid and can be pushed
  bool isValid() {
    for (var field in fields) {
      if (!field.isValid()) {
        return false;
      }
    }
    return true;
  }
}

/// A field in a content path.
mixin PathMixin implements ContentPath {
  @override
  String toPathString() {
    var sb = StringBuffer();
    for (var field in fields) {
      sb.write(ContentPath.separator);
      sb.write(field.toPathStringPart());
    }
    if (sb.isEmpty) {
      return ContentPath.separator;
    }
    return sb.toString();
  }

  @override
  void fromPath(ContentPath path) {
    for (var field in fields) {
      field.value = path.field(field.name)?.value;
    }
  }

  @override
  Map<String?, String?> toStringMap() => fields.toStringMap();

  /// True for: (* stands for null) /one/*/two/* matching /one/34/two/27
  @override
  bool matchesPath(ContentPath? path) {
    if (fields.length == path!.fields.length) {
      for (var i = 0; i < fields.length; i++) {
        var f1 = fields[i];
        var f2 = path.fields[i];
        if (!f1.matchesField(f2)) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  /// True for: (* stands for null) /one/*/two/* matching /one/34/two/27
  @override
  bool startsWith(ContentPath path) {
    if (fields.length >= path.fields.length) {
      for (var i = 0; i < path.fields.length; i++) {
        var f1 = fields[i];
        var f2 = path.fields[i];
        if (!f1.matchesField(f2)) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => fields.isEmpty ? 0 : fields.first.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ContentPath) {
      if (!const ListEquality<ContentPathField>().equals(
        other.fields,
        fields,
      )) {
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  ContentPathField? field(String? name) =>
      fields.firstWhereOrNull((field) => field.name == name);

  @override
  String toString() => '$runtimeType(${toPathString()})';
}

/// root content path.
final ContentPath rootContentPath = RootContentPath();

/// Root content path '/'
final rootContentPathString = rootContentPath.toPathString();

/// Root content path.
class RootContentPath extends ContentPathBase {
  @override
  List<ContentPathField> get fields => const <ContentPathField>[];
}

class _ContentPath extends ContentPathBase {
  @override
  final List<ContentPathField> fields;

  _ContentPath(this.fields);
}
/*
class _ContentPath with PathMixin implements ContentPath {
  @override
  final List<ContentPathPart> fields;

  _ContentPath(this.fields);
}*/

class _PathFromPath with PathMixin implements ContentPath {
  @override
  final fields = <ContentPathField>[];

  _PathFromPath(String path) {
    var parts = p.url.split(path);
    if (parts.isNotEmpty) {
      // devPrint(parts);
      var start = 0;
      if (parts[0] == ContentPath.separator) {
        start++;
      }
      var end = parts.length;
      if (parts[end - 1] == ContentPath.separator) {
        end--;
      }
      for (var i = start; i < end; i++) {
        var name = parts[i++];
        String? value;
        ContentPathField field;
        if (i < end) {
          value = parts[i];
          // Won't set if null however cannot happen
          field = ContentPathField(name, value);
        } else {
          field = ContentPathPart(name);
        }
        fields.add(field);
      }
    }
  }

  @override
  String toString() => toPathString();
}
