import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';
import 'api_interceptors.dart';

/// Centralized API Client Wrapper
/// Enforces Fixsy Constitution Principle II and api-standards skill.
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  Future<String?> Function()? _tokenProvider;
  VoidCallback? _onUnauthorized;

  /// Singleton access or factory
  factory ApiClient({
    Dio? customDio,
    Future<String?> Function()? tokenProvider,
    VoidCallback? onUnauthorized,
  }) {
    _instance ??= ApiClient._internal(
      customDio: customDio,
      tokenProvider: tokenProvider,
      onUnauthorized: onUnauthorized,
    );
    return _instance!;
  }

  ApiClient._internal({
    Dio? customDio,
    Future<String?> Function()? tokenProvider,
    VoidCallback? onUnauthorized,
  }) {
    _tokenProvider = tokenProvider;
    _onUnauthorized = onUnauthorized;

    final options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: ApiEndpoints.sendTimeout,
      headers: Map<String, dynamic>.from(ApiEndpoints.defaultHeaders),
    );

    _dio = customDio ?? Dio(options);

    _setupInterceptors();
  }

  /// Reset or reconfigure instance (useful in tests or when user logs out)
  static void reset() {
    _instance = null;
  }

  /// Configure authentication callbacks
  void configureAuth({
    Future<String?> Function()? tokenProvider,
    VoidCallback? onUnauthorized,
  }) {
    _tokenProvider = tokenProvider;
    _onUnauthorized = onUnauthorized;
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.addAll([
      AuthInterceptor(tokenProvider: _tokenProvider),
      LoggingInterceptor(),
      UnauthorizedInterceptor(onUnauthorized: _onUnauthorized),
    ]);
  }

  Dio get dio => _dio;

  /// Safe request execution wrapper
  /// Automatically catches DioException and maps to structured ApiException
  Future<Response<T>> safeRequest<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('حدث خطأ غير متوقع: $e', originalError: e);
    }
  }

  /// Standard GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    final effectiveOptions = _mergeOptions(options, requiresAuth);
    return safeRequest(() => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: effectiveOptions,
          cancelToken: cancelToken,
        ));
  }

  /// Standard POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    final effectiveOptions = _mergeOptions(options, requiresAuth);
    return safeRequest(() => _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: effectiveOptions,
          cancelToken: cancelToken,
        ));
  }

  /// Standard PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    final effectiveOptions = _mergeOptions(options, requiresAuth);
    return safeRequest(() => _dio.put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: effectiveOptions,
          cancelToken: cancelToken,
        ));
  }

  /// Standard PATCH Request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    final effectiveOptions = _mergeOptions(options, requiresAuth);
    return safeRequest(() => _dio.patch<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: effectiveOptions,
          cancelToken: cancelToken,
        ));
  }

  /// Standard DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    final effectiveOptions = _mergeOptions(options, requiresAuth);
    return safeRequest(() => _dio.delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: effectiveOptions,
          cancelToken: cancelToken,
        ));
  }

  Options _mergeOptions(Options? options, bool requiresAuth) {
    final base = options ?? Options();
    final extra = Map<String, dynamic>.from(base.extra ?? {});
    extra['requiresAuth'] = requiresAuth;
    return base.copyWith(extra: extra);
  }
}
