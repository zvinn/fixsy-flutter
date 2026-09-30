import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Interceptor to automatically attach Auth Bearer tokens
/// Complies with Fixsy Constitution Principle II & III.
class AuthInterceptor extends Interceptor {
  final Future<String?> Function()? _tokenProvider;

  AuthInterceptor({Future<String?> Function()? tokenProvider})
      : _tokenProvider = tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if request allows auth
    final bool requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth && _tokenProvider != null) {
      final token = await _tokenProvider!();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }
}

/// Structured Logging Interceptor for Debug Mode
/// Complies with Fixsy Constitution Principle V.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.debug('🌐 [API Request] ${options.method} ${options.uri}');
      if (options.data != null) {
        AppLogger.debug('📦 [Payload]: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.info(
        '✅ [API Response] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.error(
        '❌ [API Error] ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri}: ${err.message}',
        error: err.error,
      );
    }
    handler.next(err);
  }
}

/// Unauthorized (401) Interceptor to handle session expiration cleanly
class UnauthorizedInterceptor extends Interceptor {
  final VoidCallback? onUnauthorized;

  UnauthorizedInterceptor({this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      AppLogger.warn('🔒 Session expired (401 Unauthorized). Triggering auth refresh or logout.');
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
