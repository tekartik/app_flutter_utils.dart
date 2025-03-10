abstract class CvUiValueRef {
  /// Path to the value
  List<Object> get pathParts;

  factory CvUiValueRef({required List<Object> pathParts}) {
    var lastPart = pathParts.last;
    if (lastPart is int) {
      return CvUiListItemValueRef(index: lastPart, pathParts: pathParts);
    } else if (lastPart is String) {
      return CvUiFieldValueRef(key: lastPart, pathParts: pathParts);
    } else {
      throw UnsupportedError('Unsupported type $lastPart');
    }
  }
}

abstract class _CvUiValueRefBase implements CvUiValueRef {
  @override
  final List<Object> pathParts;

  _CvUiValueRefBase({required this.pathParts});

  @override
  String toString() => pathParts.join('.');
}

class CvUiFieldValueRef extends _CvUiValueRefBase {
  final String key;

  CvUiFieldValueRef({required this.key, required super.pathParts});
}

class CvUiListItemValueRef extends _CvUiValueRefBase {
  final int index;

  CvUiListItemValueRef({required this.index, required super.pathParts});
}
