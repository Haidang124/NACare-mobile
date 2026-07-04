/// Outcome of a repository call: success with data, or failure with a message.
///
/// Used instead of throwing exceptions straight to the UI — the UI (via Riverpod's
/// AsyncValue) only switches on [AppFailure]/data, with no per-widget try/catch.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Failure<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }

  /// Returns the data on success, throws the [AppFailure] on failure.
  ///
  /// Used inside a FutureProvider so Riverpod captures the error into AsyncValue.error —
  /// shorter than repeating `result.when(success: (d) => d, failure: (f) => throw f)` in every provider.
  T get dataOrThrow => when(success: (data) => data, failure: (f) => throw f);
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final AppFailure failure;
}

/// A user-displayable domain error — never leaks technical details.
class AppFailure implements Exception {
  const AppFailure(this.message, {this.retryable = true});

  factory AppFailure.network() => const AppFailure(
        'Không có kết nối mạng. Vui lòng kiểm tra và thử lại.',
      );

  factory AppFailure.server() => const AppFailure(
        'Hệ thống đang gặp sự cố. Vui lòng thử lại sau.',
      );

  factory AppFailure.notFound() => const AppFailure(
        'Không tìm thấy dữ liệu.',
        retryable: false,
      );

  final String message;
  final bool retryable;

  @override
  String toString() => 'AppFailure($message)';
}
