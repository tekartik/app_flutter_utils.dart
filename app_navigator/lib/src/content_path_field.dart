const _wildcard = '*';
const _part = '';

/// A field in a content path
///
/// value '*' is a wildcard value (translated to null), value '' is a simple part without value
class ContentPathField {
  final String name;

  /// The field value, null for any
  String get value => _value;
  String _value;
  set value(String value) {
    if (value == _wildcard) {
      value = null;
    } else if (value != null && _value != value) {
      assert(_value == null,
          '$name field value $_value cannot be changed to $value. It can only be set once');
    }
    _value = value;
  }

  ContentPathField(this.name, [String value])
      : _value = value == _wildcard ? null : value {
    assert(name != null, 'ContentPathField name cannot be null');
  }

  @override
  int get hashCode => super.hashCode + (value?.hashCode ?? 0);

  @override
  bool operator ==(other) {
    if (other is ContentPathField) {
      if (other.name != name) {
        return false;
      }
      if (other.value != value) {
        return false;
      }
      return true;
    }
    return false;
  }

  /// True for: (* stands for null) /one/*/two/* matching /one/34/two/27
  bool matchesField(ContentPathField field) {
    if (field.name == name) {
      if (field.value == null) {
        if (value == _part) {
          return false;
        }
        return true;
      } else if (value == null) {
        if (field.value == _part) {
          return false;
        }
        return true;
      }
      return field.value == value;
    }
    return false;
  }

  @override
  String toString() => '$name:$value';

  String toPath() {
    if (value == null) {
      return '$name/$_wildcard';
    } else if (value == _part) {
      return name;
    } else {
      return '$name/$value';
    }
  }
}

extension ContentFieldListExt on List<ContentPathField> {
  Map<String, String> toStringMap() {
    var map = <String, String>{};
    forEach((field) {
      map[field.name] = field.value;
    });
    return map;
  }
}
