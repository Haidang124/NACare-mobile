import 'package:dio/dio.dart';

import '../config/app_env.dart';
import 'error_mapper.dart';
import 'result.dart';
import 'token_store.dart';

/// Gọi khi phát hiện 401 trên một endpoint cần đăng nhập (đã thử refresh mà không được).
typedef UnauthorizedCallback = void Function();

/// Dựng [Dio] dùng chung cho toàn app. Mọi thứ "cross-cutting" gom hết vào đây một
/// lần, để từng repository chỉ việc gọi path + parse JSON:
///   - baseUrl + timeout
///   - header `tenant` (bắt buộc cho BE đa tenant)
///   - gắn `Authorization: Bearer <token>` cho endpoint cần đăng nhập
///   - 401 → (TODO refresh) hiện tại xoá phiên + báo lên trên để về màn đăng nhập
///
/// Hàm này **không** import feature nào — chỉ nhận [tokens] và callback, nên tái sử
/// dụng và test được độc lập. Phần wiring session nằm ở `dioProvider`.
Dio buildDio({
  required AppEnv env,
  required TokenStore tokens,
  UnauthorizedCallback? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'tenant': env.tenant},
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Các endpoint patient/auth/* là public — không gắn token (tránh gửi token cũ).
        if (!_isAuthPath(options.path)) {
          final token = await tokens.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        final status = e.response?.statusCode;
        if (status == 401 && !_isAuthPath(e.requestOptions.path)) {
          // TODO(refresh): thử đổi refresh token 1 lần rồi retry request gốc;
          // chỉ khi refresh thất bại mới xoá phiên. Hiện tại (bản stub) 401 = mất phiên.
          await tokens.clear();
          onUnauthorized?.call();
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}

bool _isAuthPath(String path) => path.contains('/patient/auth/');

/// Bọc một call trả dữ liệu về [Result], chuẩn hoá mọi lỗi kỹ thuật thành [AppFailure]
/// qua [mapHttpError]. UI/presentation nhờ vậy không bao giờ thấy `DioException`.
Future<Result<T>> apiCall<T>(
  Future<Response<dynamic>> Function() send,
  T Function(dynamic json) parse,
) async {
  try {
    final res = await send();
    return Result.success(parse(res.data));
  } on DioException catch (e) {
    return Result.failure(mapHttpError(e, statusCode: e.response?.statusCode));
  } catch (_) {
    return Result.failure(AppFailure.server());
  }
}

/// Biến thể cho call không có payload trả về (POST/DELETE trả 200/204 rỗng).
Future<Result<void>> apiCallVoid(
  Future<Response<dynamic>> Function() send,
) async {
  try {
    await send();
    return const Result.success(null);
  } on DioException catch (e) {
    return Result.failure(mapHttpError(e, statusCode: e.response?.statusCode));
  } catch (_) {
    return Result.failure(AppFailure.server());
  }
}
