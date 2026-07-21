import 'parse_failure.dart';

class ParseException implements Exception {
  const ParseException(this.failure);

  final ParseFailure failure;
}
