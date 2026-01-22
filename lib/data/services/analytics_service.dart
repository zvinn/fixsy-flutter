import 'package:firebase_analytics/firebase_analytics.dart';
import '../../core/utils/app_logger.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = 
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a custom event
  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      AppLogger.info('Analytics Event: $name', error: parameters);
    } catch (e) {
      AppLogger.error('Failed to log analytics event: $e');
    }
  }

  /// Log user login
  static Future<void> logLogin({String? method}) async {
    await logEvent('login', parameters: {
      'method': method ?? 'email',
    });
  }

  /// Log user registration
  static Future<void> logSignUp({String? method}) async {
    await logEvent('sign_up', parameters: {
      'method': method ?? 'email',
    });
  }

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Log booking request
  static Future<void> logBookingRequest({
    required String serviceType,
    required double price,
    String? couponCode,
  }) async {
    await logEvent('booking_request', parameters: {
      'service_type': serviceType,
      'value': price,
      'currency': 'EGP',
      'coupon_used': couponCode != null,
    });
  }

  /// Log payment success
  static Future<void> logPaymentSuccess({
    required String orderId,
    required double amount,
    required String method,
  }) async {
    await logEvent('purchase', parameters: {
      'transaction_id': orderId,
      'value': amount,
      'currency': 'EGP',
      'payment_method': method,
    });
  }

  /// Log search
  static Future<void> logSearch(String term) async {
    await _analytics.logSearch(searchTerm: term);
  }
}
