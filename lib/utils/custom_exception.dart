class CustomException implements Exception {
  final String? code;
  final String message;

  const CustomException({this.code, required this.message});

  @override
  String toString() => code == null ? message : '[$code] $message';
}
