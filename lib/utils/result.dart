import 'custom_exception.dart';

sealed class Result<S, E extends CustomException> {
  const Result();
}

final class Success<S, E extends CustomException> extends Result<S, E> {
  const Success(this.value, {this.successCode});

  final S value;
  final String? successCode;
}

final class Failure<S, E extends CustomException> extends Result<S, E> {
  const Failure(this.exception);

  final E exception;
}
