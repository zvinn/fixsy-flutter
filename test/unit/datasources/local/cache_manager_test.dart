import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixsy_flutter/data/datasources/local/cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CacheManager cacheManager;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cacheManager = CacheManager();
  });

  group('CacheManager Unit Tests', () {
    test('put and get unexpired item returns data correctly', () async {
      final testData = {'id': 'service_1', 'title': 'Plumbing Repair', 'price': 150};
      await cacheManager.put('test_service', testData, ttl: const Duration(hours: 1));

      final result = await cacheManager.get('test_service');
      expect(result, isNotNull);
      expect(result['id'], equals('service_1'));
      expect(result['title'], equals('Plumbing Repair'));
      expect(result['price'], equals(150));
    });

    test('get non-existent key returns null', () async {
      final result = await cacheManager.get('non_existent_key');
      expect(result, isNull);
    });

    test('get expired item with ignoreExpired=false returns null', () async {
      final testData = {'status': 'expired_item'};
      // Set TTL to negative duration so it's already expired
      await cacheManager.put('expired_key', testData, ttl: const Duration(seconds: -10));

      final result = await cacheManager.get('expired_key', ignoreExpired: false);
      expect(result, isNull);
    });

    test('get expired item with ignoreExpired=true returns stale data for offline fallback', () async {
      final testData = {'status': 'stale_item_for_offline'};
      await cacheManager.put('stale_key', testData, ttl: const Duration(seconds: -10));

      final result = await cacheManager.get('stale_key', ignoreExpired: true);
      expect(result, isNotNull);
      expect(result['status'], equals('stale_item_for_offline'));
    });

    test('hasValid returns true for fresh item and false for expired item', () async {
      await cacheManager.put('fresh_key', 'valid_data', ttl: const Duration(minutes: 10));
      await cacheManager.put('old_key', 'old_data', ttl: const Duration(seconds: -5));

      expect(await cacheManager.hasValid('fresh_key'), isTrue);
      expect(await cacheManager.hasValid('old_key'), isFalse);
      expect(await cacheManager.hasValid('missing_key'), isFalse);
    });

    test('remove deletes specific key', () async {
      await cacheManager.put('key_to_delete', 'value', ttl: const Duration(hours: 1));
      expect(await cacheManager.hasValid('key_to_delete'), isTrue);

      await cacheManager.remove('key_to_delete');
      expect(await cacheManager.get('key_to_delete'), isNull);
    });

    test('clearPrefix removes all keys matching prefix', () async {
      await cacheManager.put('booking_user_1', {'id': 1}, ttl: const Duration(hours: 1));
      await cacheManager.put('booking_user_2', {'id': 2}, ttl: const Duration(hours: 1));
      await cacheManager.put('user_profile_1', {'name': 'Ali'}, ttl: const Duration(hours: 1));

      await cacheManager.clearPrefix('booking_');

      expect(await cacheManager.get('booking_user_1'), isNull);
      expect(await cacheManager.get('booking_user_2'), isNull);
      expect(await cacheManager.get('user_profile_1'), isNotNull);
    });
  });
}
