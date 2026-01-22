import 'package:flutter/foundation.dart';
import '../../core/utils/app_logger.dart';

class ErrorLogger {
  static Future<void> init() async {
    // Initialize Sentry or other crash reporting services here
    // await SentryFlutter.init(...)
    AppLogger.info('Error Logger initialized');
  }

  static void logError(dynamic exception, StackTrace? stackTrace, {String? reason, bool fatal = false}) {
    AppLogger.error(reason ?? 'An error occurred', error: exception, stackTrace: stackTrace);
    
    if (!kDebugMode) {
      // Send to Sentry / Firebase Crashlytics
      // FirebaseCrashlytics.instance.recordError(exception, stackTrace, reason: reason, fatal: fatal);
    }
  }

  static void logFlutterError(FlutterErrorDetails details) {
    AppLogger.fatal('Flutter Error', error: details.exception, stackTrace: details.stack);
    
    if (!kDebugMode) {
      // FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  }
}
