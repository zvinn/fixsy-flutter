import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Offline Indicator Widget
/// Shows a banner when the device is offline
class OfflineIndicator extends StatefulWidget {
  final Widget child;
  final bool showBanner;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  @override
  Widget build(BuildContext context) {
    if (!widget.showBanner) {
      return widget.child;
    }

    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            if (!provider.isOnline)
              const OfflineBanner().animate().slideY(begin: -1, end: 0).fadeIn(),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}



/// Offline Banner - Shows at top of screen
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.red.shade600,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offline Overlay - Shows over content when offline
class OfflineOverlay extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineOverlay({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark 
          ? Colors.black.withOpacity(0.9)
          : Colors.white.withOpacity(0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ).animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'لا يوجد اتصال بالإنترنت',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Connection Status Widget - Small indicator
class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, _) {
        final isOnline = provider.isOnline;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                isOnline ? 'متصل' : 'غير متصل',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
