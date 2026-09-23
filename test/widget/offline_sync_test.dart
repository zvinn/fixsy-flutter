import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/presentation/providers/connectivity_provider.dart';
import 'package:fixsy_flutter/presentation/widgets/common/offline_indicator.dart';

void main() {
  group('ConnectivityProvider & Offline Sync Tests', () {
    test('enqueues task and updates pending count', () {
      final provider = ConnectivityProvider(initialOnline: false, autoInit: false);

      expect(provider.pendingCount, 0);

      final task = SyncTask(
        id: 'task_1',
        type: SyncTaskType.booking,
        title: 'طلب حجز سباكة',
        description: 'المعادي - القاهرة',
        createdAt: DateTime.now(),
      );

      provider.enqueueTask(task);
      expect(provider.pendingCount, 1);
      expect(provider.syncQueue.first.title, 'طلب حجز سباكة');
    });

    test('reconnection automatically triggers sync when online', () async {
      final provider = ConnectivityProvider(initialOnline: false, autoInit: false);

      provider.enqueueTask(
        SyncTask(
          id: 'task_2',
          type: SyncTaskType.rating,
          title: 'تقييم فني معلق',
          createdAt: DateTime.now(),
        ),
      );

      expect(provider.pendingCount, 1);

      // Reconnect
      provider.setOnlineStatus(true);
      expect(provider.isOnline, true);
      expect(provider.justReconnected, true);

      // Wait for simulated sync
      await Future.delayed(const Duration(milliseconds: 700));
      expect(provider.pendingCount, 0);
      expect(provider.syncQueue.first.isSynced, true);
    });

    testWidgets('renders offline banner when offline', (tester) async {
      final provider = ConnectivityProvider(initialOnline: false, autoInit: false);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                child: Center(child: Text('محتوى الصفحة')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('محتوى الصفحة'), findsOneWidget);
      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.textContaining('وضع عدم الاتصال'), findsOneWidget);
    });

    testWidgets('renders sync queue badge and opens sync modal', (tester) async {
      final provider = ConnectivityProvider(initialOnline: false, autoInit: false);
      provider.enqueueTask(
        SyncTask(
          id: 'task_3',
          type: SyncTaskType.booking,
          title: 'حجز كهرباء منزلي',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                child: Center(child: Text('الشاشة الرئيسية')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 معلق'), findsOneWidget);

      // Tap on queue pill
      await tester.tap(find.text('1 معلق'));
      await tester.pumpAndSettle();

      expect(find.text('طابور المزامنة دون اتصال'), findsOneWidget);
      expect(find.text('حجز كهرباء منزلي'), findsOneWidget);
      expect(find.text('• معلق ⏳'), findsOneWidget);
    });
  });
}
