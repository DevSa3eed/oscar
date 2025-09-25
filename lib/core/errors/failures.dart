abstract class Failure {
  const Failure();

  String get message;

  R when<R>({
    required R Function(String message) serverError,
    required R Function(String message) networkError,
    required R Function(String message) authError,
    required R Function(String message) validationError,
    required R Function(String message) notFoundError,
    required R Function(String message) permissionError,
    required R Function(String message) unknownError,
  }) {
    if (this is ServerError) {
      return serverError(message);
    } else if (this is NetworkError) {
      return networkError(message);
    } else if (this is AuthError) {
      return authError(message);
    } else if (this is ValidationError) {
      return validationError(message);
    } else if (this is NotFoundError) {
      return notFoundError(message);
    } else if (this is PermissionError) {
      return permissionError(message);
    } else if (this is UnknownError) {
      return unknownError(message);
    } else {
      return unknownError(message);
    }
  }
}

class ServerError extends Failure {
  final String _message;

  const ServerError(this._message);

  @override
  String get message => _message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServerError && other._message == _message;
  }

  @override
  int get hashCode => _message.hashCode;

  @override
  String toString() => 'ServerError($_message)';
}

class NetworkError extends Failure {
  final String _message;

  const NetworkError(this._message);

  @override
  String get message => _message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkError && other._message == _message;
  }

  @override
  int get hashCode => _message.hashCode;

  @override
  String toString() => 'NetworkError($_message)';
}

class AuthError extends Failure {
  final String _message;

  const AuthError(this._message);

  @override
  String get message => _message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError && other._message == _message;
  }

  @override
  int get hashCode => _message.hashCode;

  @override
  String toString() => 'AuthError($_message)';
}

class ValidationError extends Failure {
  final String _message;

  const ValidationError(this._message);

  @override
  String get message => _message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationError && other._message == _message;
  }

  @override
  int get hashCode => _message.hashCode;

  @override
  String toString() => 'ValidationError($_message)';
}

class NotFoundError extends Failure {
  final String _message;

  const NotFoundError(this._message);

  @override
  String get message => _message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotFoundError && other._message == _message;
  }

  @override
  int get hashCode => _message.hashCode;

  @override
  String toString() => 'NotFoundError($_message)';
}

class PermissionError extends Failure {
  final String _message;

  const PermissionError(this._message);

  @override
  String get message => _message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermissionError && other._message == _message;
  }

  @override
  int get hashCode => _message.hashCode;

  @override
  String toString() => 'PermissionError($_message)';
}

class UnknownError extends Failure {
  final String _message;

  const UnknownError(this._message);

  @override
  String get message => _message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnknownError && other._message == _message;
  }

  @override
  int get hashCode => _message.hashCode;

  @override
  String toString() => 'UnknownError($_message)';
}
