/// Result type wrapper using dartz Either for functional error handling
/// Provides a convenient way to handle success/failure cases

import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Result type alias for Either<Failure, T>
/// 
/// Usage:
/// ```dart
/// Result<User> result = await getUser(id);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (user) => print('Success: ${user.name}'),
/// );
/// ```
typedef Result<T> = Either<Failure, T>;

/// Async Result type alias for Future<Either<Failure, T>>
/// 
/// Usage:
/// ```dart
/// AsyncResult<User> result = fetchUser(id);
/// final user = await result.fold(
///   (failure) => throw Exception(failure.message),
///   (user) => user,
/// );
/// ```
typedef AsyncResult<T> = Future<Either<Failure, T>>;

/// Stream Result type alias for Stream<Either<Failure, T>>
typedef StreamResult<T> = Stream<Either<Failure, T>>;

/// Extension methods for Result type
extension ResultExtension<T> on Result<T> {
  /// Check if the result is a success
  bool get isSuccess => isRight();

  /// Check if the result is a failure
  bool get isFailure => isLeft();

  /// Get the success value or null if failure
  T? getOrNull() {
    return fold((_) => null, (value) => value);
  }

  /// Get the failure or null if success
  Failure? getFailureOrNull() {
    return fold((failure) => failure, (_) => null);
  }

  /// Get the success value or throw the failure as an exception
  T getOrThrow() {
    return fold(
      (failure) => throw _FailureException(failure),
      (value) => value,
    );
  }

  /// Get the success value or the default value if failure
  T getOrElse(T defaultValue) {
    return fold((_) => defaultValue, (value) => value);
  }

  /// Get the success value or compute it lazily if failure
  T getOrElseLazy(T Function() defaultValue) {
    return fold((_) => defaultValue(), (value) => value);
  }

  /// Transform the success value
  Result<R> map<R>(R Function(T) mapper) {
    return flatMap((value) => right<Failure, R>(mapper(value)));
  }

  /// Transform the success value with a function that returns a Result
  Result<R> flatMap<R>(Result<R> Function(T) mapper) {
    return fold(
      (failure) => left<Failure, R>(failure),
      (value) => mapper(value),
    );
  }

  /// Transform the failure
  Result<T> mapFailure(Failure Function(Failure) mapper) {
    return fold(
      (failure) => left<Failure, T>(mapper(failure)),
      (value) => right<Failure, T>(value),
    );
  }

  /// Handle both cases and return a value
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return fold(onFailure, onSuccess);
  }

  /// Execute a side effect on success
  Result<T> onSuccess(void Function(T) callback) {
    return fold(
      (failure) => left<Failure, T>(failure),
      (value) {
        callback(value);
        return right<Failure, T>(value);
      },
    );
  }

  /// Execute a side effect on failure
  Result<T> onFailure(void Function(Failure) callback) {
    return fold(
      (failure) {
        callback(failure);
        return left<Failure, T>(failure);
      },
      (value) => right<Failure, T>(value),
    );
  }

  /// Convert to Option - Some(value) if success, None if failure
  Option<T> toOption() {
    return fold((_) => const None(), (value) => Some(value));
  }

  /// Convert to nullable value
  T? toNullable() => getOrNull();
}

/// Extension methods for AsyncResult type
extension AsyncResultExtension<T> on AsyncResult<T> {
  /// Await and get the Result
  Future<Result<T>> awaitResult() async => await this;

  /// Get the success value or null if failure
  Future<T?> getOrNull() async {
    return (await this).fold((_) => null, (value) => value);
  }

  /// Get the success value or the default value if failure
  Future<T> getOrElse(T defaultValue) async {
    return (await this).fold((_) => defaultValue, (value) => value);
  }

  /// Get the success value or compute it lazily if failure
  Future<T> getOrElseLazy(Future<T> Function() defaultValue) async {
    return (await this).fold((_) => defaultValue(), (value) => value);
  }

  /// Transform the success value
  Future<Result<R>> map<R>(R Function(T) mapper) async {
    return (await this).flatMap((value) => right<Failure, R>(mapper(value)));
  }

  /// Transform the success value with a function that returns an AsyncResult
  Future<Result<R>> flatMapAsync<R>(AsyncResult<R> Function(T) mapper) async {
    final result = await this;
    return result.fold<Future<Result<R>>>(
      (failure) => Future.value(left<Failure, R>(failure)),
      (value) => mapper(value),
    );
  }

  /// Execute a side effect on success
  Future<Result<T>> onSuccess(Future<void> Function(T) callback) async {
    return (await this).fold(
      (failure) => left<Failure, T>(failure),
      (value) async {
        await callback(value);
        return right<Failure, T>(value);
      },
    );
  }

  /// Execute a side effect on failure
  Future<Result<T>> onFailure(Future<void> Function(Failure) callback) async {
    return (await this).fold(
      (failure) async {
        await callback(failure);
        return left<Failure, T>(failure);
      },
      (value) => right<Failure, T>(value),
    );
  }
}

/// Exception wrapper for failures
class _FailureException implements Exception {
  final Failure failure;

  const _FailureException(this.failure);

  @override
  String toString() => 'FailureException: ${failure.message}';
}

/// Helper functions for creating Result instances
class ResultHelper {
  /// Create a success Result
  static Result<T> success<T>(T value) => Right<Failure, T>(value);

  /// Create a failure Result
  static Result<T> failure<T>(Failure failure) => Left<Failure, T>(failure);

  /// Create a failure Result from a message
  static Result<T> error<T>(String message, {String? code, dynamic originalError}) {
    return Left<Failure, T>(
      UnknownFailure(message: message, originalError: originalError),
    );
  }

  /// Run a function and catch any exceptions, returning a Result
  static Result<T> guard<T>(T Function() fn) {
    try {
      return success(fn());
    } catch (e) {
      return failure(UnknownFailure(message: e.toString(), originalError: e));
    }
  }

  /// Run an async function and catch any exceptions, returning an AsyncResult
  static AsyncResult<T> guardAsync<T>(Future<T> Function() fn) async {
    try {
      return success(await fn());
    } catch (e) {
      return failure(UnknownFailure(message: e.toString(), originalError: e));
    }
  }

  /// Convert a nullable value to a Result
  static Result<T> fromNullable<T>(T? value, {required String message}) {
    if (value == null) {
      return failure(UnknownFailure(message: message, code: 'NULL_VALUE'));
    }
    return success(value);
  }

  /// Convert a boolean condition to a Result
  static Result<T> fromCondition<T>(
    bool condition,
    T value, {
    required String message,
    String? code,
  }) {
    if (!condition) {
      return failure(UnknownFailure(message: message, code: code ?? 'CONDITION_NOT_MET'));
    }
    return success(value);
  }
}

/// Try-Catch helper for functional error handling
class Try<T> {
  final Result<T> _result;

  Try._(this._result);

  /// Create a Try from a function that may throw
  factory Try.of(T Function() fn) {
    try {
      return Try._(Result.success(fn()));
    } catch (e) {
      return Try._(Result.failure(UnknownFailure(message: e.toString(), originalError: e)));
    }
  }

  /// Get the Result
  Result<T> get result => _result;

  /// Map over the success value
  Try<R> map<R>(R Function(T) mapper) {
    return Try._(_result.map(mapper));
  }

  /// FlatMap over the success value
  Try<R> flatMap<R>(Try<R> Function(T) mapper) {
    return _result.fold(
      (failure) => Try._(Result.failure(failure)),
      (value) => mapper(value),
    );
  }

  /// Get the value or a default
  T getOrElse(T defaultValue) => _result.getOrElse(defaultValue);

  /// Fold into a single value
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return _result.fold(onFailure, onSuccess);
  }
}
