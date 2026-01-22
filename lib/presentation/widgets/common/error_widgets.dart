import 'package:flutter/material.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/app_error_handler.dart';
import '../../core/theme/app_theme.dart';

/// Error Retry Widget
/// Beautiful error UI with retry functionality
class ErrorRetryWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;
  final String? customMessage;
  final bool showDetails;

  const ErrorRetryWidget({
    Key? key,
    required this.error,
    required this.onRetry,
    this.customMessage,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorMessage = customMessage ?? AppErrorHandler.getUserMessage(error);
    final isRecoverable = AppErrorHandler.isRecoverable(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(),
                size: 64,
                color: AppTheme.errorColor,
              ),
            ),

            const SizedBox(height: 24),

            // Error Title
            Text(
              _getErrorTitle(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Error Message
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Show error details in debug mode
            if (showDetails && error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Retry Button (only for recoverable errors)
            if (isRecoverable)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),

            // Contact Support (for non-recoverable errors)
            if (!isRecoverable) ...[
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to support/contact screen
                },
                icon: const Icon(Icons.support_agent),
                label: const Text('التواصل مع الدعم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('العودة'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    if (error is NoInternetException) {
      return Icons.wifi_off;
    }
    if (error is NetworkException) {
      return Icons.cloud_off;
    }
    if (error is AuthException) {
      return Icons.lock_outline;
    }
    if (error is ValidationException) {
      return Icons.error_outline;
    }
    return Icons.error_outline;
  }

  String _getErrorTitle() {
    if (error is NoInternetException) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    if (error is NetworkException) {
      return 'خطأ في الاتصال';
    }
    if (error is AuthException) {
      return 'خطأ في المصادقة';
    }
    if (error is ValidationException) {
      return 'بيانات غير صحيحة';
    }
    return 'حدث خطأ';
  }
}

/// Compact Error Widget (for inline errors)
class CompactErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const CompactErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorMessage = AppErrorHandler.getUserMessage(error);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: AppTheme.errorColor,
            ),
        ],
      ),
    );
  }
}
