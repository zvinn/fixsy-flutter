import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'exceptions.dart';
import '../utils/app_logger.dart';

/// Global Error Handler for Fixsy Flutter
/// Catches and handles all app errors gracefully
class AppErrorHandler {
  static final AppErrorHandler _instance = AppErrorHandler._internal();
  factory AppErrorHandler() => _instance;
  AppErrorHandler._internal();

  /// Initialize error handler
  static Future<void> initialize() async {
    // Set up Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _instance.handleFlutterError(details);
    };

    // Set up platform dispatcher error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      _instance.handleError(error, stack);
      return true;
    };

    AppLogger.info('Error handler initialized');
  }

  /// Handle Flutter framework errors
  void handleFlutterError(FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter Error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );

    // Log to Crashlytics in release mode
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  }

  /// Handle general errors
  void handleError(Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Error: $error',
      error: error,
      stackTrace: stackTrace,
    );

    // Log to Crashlytics in release mode
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    }
  }

  /// Get user-friendly error message from exception
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is NetworkException) {
      return error.message;
    }

    if (error is AuthException) {
      return error.message;
    }

    if (error is ValidationException) {
      return error.message;
    }

    if (error is FirestoreException) {
      return error.message;
    }

    // Handle Firebase errors
    if (error.toString().contains('network-request-failed')) {
      return 'لا يوجد اتصال بالإنترنت';
    }

    if (error.toString().contains('permission-denied')) {
      return 'ليس لديك صلاحية للوصول';
    }

    if (error.toString().contains('too-many-requests')) {
      return 'تم تجاوز الحد المسموح. يرجى المحاولة لاحقاً';
    }

    // Default error message
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }

  /// Check if error is recoverable
  static bool isRecoverable(dynamic error) {
    // Network errors are usually recoverable
    if (error is NetworkException ||
        error is TimeoutException ||
        error is NoInternetException) {
      return true;
    }

    // Some auth errors are recoverable
    if (error is SessionExpiredException) {
      return true;
    }

    // Validation errors are recoverable
    if (error is ValidationException) {
      return true;
    }

    return false;
  }

  /// Log error to analytics
  static void logToAnalytics(dynamic error, {String? screen}) {
    try {
      final errorName = error.runtimeType.toString();
      final errorMessage = error.toString();

      AppLogger.error(
        'Analytics Error Log',
        error: {
          'name': errorName,
          'message': errorMessage,
          'screen': screen,
        },
      );

      // Log to Firebase Analytics
      // FirebaseAnalytics.instance.logEvent(
      //   name: 'app_error',
      //   parameters: {
      //     'error_type': errorName,
      //     'error_message': errorMessage,
      //     'screen': screen ?? 'unknown',
      //   },
      // );
    } catch (e) {
      AppLogger.warn('Failed to log error to analytics: $e');
    }
  }

  /// Handle API errors
  static AppException handleApiError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return NoInternetException();
    }

    if (error.toString().contains('TimeoutException')) {
      return TimeoutException();
    }

    if (error.toString().contains('404')) {
      return ServerException('الخدمة غير موجودة');
    }

    if (error.toString().contains('500') ||
        error.toString().contains('502') ||
        error.toString().contains('503')) {
      return ServerException();
    }

    return UnknownException();
  }

  /// Handle Firestore errors
  static AppException handleFirestoreError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('permission-denied')) {
      return PermissionDeniedException();
    }

    if (errorMessage.contains('not-found')) {
      return DocumentNotFoundException();
    }

    if (errorMessage.contains('network')) {
      return NoInternetException();
    }

    return FirestoreException('حدث خطأ في قاعدة البيانات');
  }

  /// Handle Auth errors
  static AuthException handleAuthError(dynamic error) {
    final errorCode = error.toString();

    if (errorCode.contains('user-not-found')) {
      return UserNotFoundException();
    }

    if (errorCode.contains('wrong-password') ||
        errorCode.contains('invalid-credential')) {
      return InvalidCredentialsException();
    }

    if (errorCode.contains('email-already-in-use')) {
      return EmailAlreadyInUseException();
    }

    if (errorCode.contains('weak-password')) {
      return WeakPasswordException();
    }

    if (errorCode.contains('user-disabled')) {
      return UserDisabledException();
    }

    if (errorCode.contains('too-many-requests')) {
      return AuthException('تم تجاوز عدد المحاولات. يرجى المحاولة لاحقاً');
    }

    return AuthException('حدث خطأ في المصادقة');
  }
}
