import '../errors/failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get data {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }

  Failure? get error {
    if (this is FailureResult<T>) {
      return (this as FailureResult<T>).failure;
    }
    return null;
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as FailureResult<T>).failure);
    }
  }

  R map<R>({
    required R Function(Success<T> success) success,
    required R Function(FailureResult<T> failure) failure,
  }) {
    if (this is Success<T>) {
      return success(this as Success<T>);
    } else {
      return failure(this as FailureResult<T>);
    }
  }

  Result<U> mapData<U>(U Function(T data) mapper) {
    if (this is Success<T>) {
      return Result.success(mapper((this as Success<T>).data));
    } else {
      return Result.failure((this as FailureResult<T>).failure);
    }
  }

  static Result<T> success<T>(T data) => Success(data);
  static Result<T> failure<T>(Failure failure) => FailureResult(failure);
}

final class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

final class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FailureResult<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'FailureResult(failure: $failure)';
}
