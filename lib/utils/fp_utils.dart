import 'package:fpdart/fpdart.dart';

/// Safely execute an async task, catching errors and converting to TaskEither
TaskEither<String, T> safeTask<T>(Future<T> Function() task) {
  return TaskEither.tryCatch(task, (error, _) => error.toString());
}

/// Safely execute a synchronous task, catching errors and converting to TaskEither
TaskEither<String, T> safe<T>(T Function() task) {
  return TaskEither.fromEither(
    Either.tryCatch(task, (error, _) => error.toString()),
  );
}

/// Extension to add filter functionality to TaskEither
/// Allows filtering values with a predicate, converting failures to Left
extension TaskEitherFilter<L, R> on TaskEither<L, R> {
  TaskEither<L, R> filter(bool Function(R) predicate, L Function(R) onFalse) {
    return flatMap(
      (value) =>
          predicate(value)
              ? TaskEither.right(value)
              : TaskEither.left(onFalse(value)),
    );
  }
}
