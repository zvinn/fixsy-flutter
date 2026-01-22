import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// App Logger
/// Centralized logging system for Fixsy Flutter
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: kDebugMode ? Level.debug : Level.info,
  );

  /// Log debug message
  static void debug(String message, {dynamic data}) {
    _logger.d(message, error: data);
  }

  /// Log info message
  static void info(String message, {dynamic data}) {
    _logger.i(message, error: data);
  }

  /// Log warning message
  static void warn(String message, {dynamic data}) {
    _logger.w(message, error: data);
  }

  /// Log error message
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal error
  static void fatal(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log API request
  static void logApiRequest(String method, String url, {dynamic data}) {
    if (kDebugMode) {
      _logger.d('API REQUEST [$method] $url', error: data);
    }
  }

  /// Log API response
  static void logApiResponse(int statusCode, String url, {dynamic data}) {
    if (kDebugMode) {
      _logger.d('API RESPONSE [$statusCode] $url', error: data);
    }
  }

  /// Log user action
  static void logUserAction(String action, {dynamic data}) {
    _logger.i('USER ACTION: $action', error: data);
  }

  /// Log navigation
  static void logNavigation(String from, String to) {
    if (kDebugMode) {
      _logger.d('NAVIGATION: $from → $to');
    }
  }
}
