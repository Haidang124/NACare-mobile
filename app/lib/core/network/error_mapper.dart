import 'result.dart';

/// Maps a network/HTTP error to a user-facing [AppFailure].
///
/// When wiring the real API, call this in **one place** — ideally inside the
/// client interceptor (e.g. Dio's `onError`) or the `Api*Repository` — so the UI
/// only ever sees a normalized [AppFailure] and technical details (status code,
/// stack trace, server error JSON...) never leak to it.
///
/// Unused during the mock phase; kept ready so swapping `Mock*Repository` for
/// `Api*Repository` doesn't require rethinking error mapping per feature.
AppFailure mapHttpError(Object error, {int? statusCode}) {
  if (statusCode != null) {
    if (statusCode == 401 || statusCode == 403) {
      return const AppFailure(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        retryable: false,
      );
    }
    if (statusCode == 404) return AppFailure.notFound();
    if (statusCode >= 500) return AppFailure.server();
    if (statusCode >= 400) {
      return const AppFailure('Yêu cầu không hợp lệ. Vui lòng thử lại.');
    }
  }
  // No status (timeout, no connection, DNS...) -> treat as a retryable network error.
  return AppFailure.network();
}
