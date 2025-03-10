enum CvUiEditResultType { cancel, ok, nullify, delete, create }

class CvUiEditTextResult extends CvUiEditResult {
  final String? value;

  CvUiEditTextResult({required super.type, this.value});
}

class CvUiEditResult {
  final CvUiEditResultType type;

  CvUiEditResult({required this.type});
}
