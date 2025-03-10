enum CvUiEditResultType { cancel, ok, nullify, delete }

class CvUiEditTextResult {
  final CvUiEditResultType type;
  final String? value;

  CvUiEditTextResult({required this.type, this.value});
}
