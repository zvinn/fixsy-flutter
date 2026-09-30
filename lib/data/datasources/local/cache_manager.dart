import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_logger.dart';

/// Generic Persistent Cache Manager with Time-To-Live (TTL)
/// Enforces Fixsy Constitution Principle IV (Offline-First Mindset).
class CacheManager {
  static CacheManager? _instance;
  SharedPreferences? _prefs;

  factory CacheManager() {
    _instance ??= CacheManager._internal();
    return _instance!;
  }

  CacheManager._internal();

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Store any JSON-encodable data with optional TTL (defaults to 24 hours)
  Future<void> put(
    String key,
    dynamic data, {
    Duration ttl = const Duration(hours: 24),
  }) async {
    try {
      final prefs = await _getPrefs();
      final now = DateTime.now();
      final expiresAt = now.add(ttl);

      final envelope = {
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'data': data,
      };

      await prefs.setString(key, jsonEncode(envelope));
    } catch (e, stack) {
      AppLogger.error('Failed to put item in CacheManager ($key)', error: e, stackTrace: stack);
    }
  }

  /// Retrieve cached data, returning null if missing or expired (unless ignoreExpired is true)
  Future<dynamic> get(
    String key, {
    bool ignoreExpired = false,
  }) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(key);
      if (raw == null) return null;

      final Map<String, dynamic> envelope = jsonDecode(raw);
      final expiresAtStr = envelope['expiresAt'] as String?;

      if (!ignoreExpired && expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiresAt)) {
          AppLogger.debug('Cache expired for key: $key');
          return null;
        }
      }

      return envelope['data'];
    } catch (e, stack) {
      AppLogger.error('Failed to get item from CacheManager ($key)', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Check whether valid (unexpired) cache exists for a key
  Future<bool> hasValid(String key) async {
    final data = await get(key, ignoreExpired: false);
    return data != null;
  }

  /// Invalidate/remove a specific cached key
  Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  /// Clear all cache entries starting with a specific prefix
  Future<void> clearPrefix(String prefix) async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
