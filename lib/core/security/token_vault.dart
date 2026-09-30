import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

/// Secure Token Vault
/// Uses hardware-backed encrypted storage for sensitive JWTs and credentials.
/// Enforces Fixsy Constitution Principle III & security-standards.
class TokenVault {
  static TokenVault? _instance;
  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = 'fixsy_access_token';
  static const String _keyRefreshToken = 'fixsy_refresh_token';
  static const String _keyUserId = 'fixsy_user_id';
  static const String _keyUserRole = 'fixsy_user_role';

  /// Factory constructor
  factory TokenVault({FlutterSecureStorage? storage}) {
    _instance ??= TokenVault._internal(
      storage: storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
          ),
    );
    return _instance!;
  }

  TokenVault._internal({required FlutterSecureStorage storage}) : _storage = storage;

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _keyAccessToken, value: token);
    } catch (e, stack) {
      AppLogger.error('Failed to securely save access token', error: e, stackTrace: stack);
    }
  }

  /// Retrieve access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (e, stack) {
      AppLogger.error('Failed to read access token from vault', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
    } catch (e, stack) {
      AppLogger.error('Failed to securely save refresh token', error: e, stackTrace: stack);
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e, stack) {
      AppLogger.error('Failed to read refresh token from vault', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Save complete session details
  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    required String userId,
    String? role,
  }) async {
    await saveAccessToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
    await _storage.write(key: _keyUserId, value: userId);
    if (role != null) {
      await _storage.write(key: _keyUserRole, value: role);
    }
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      return null;
    }
  }

  /// Retrieve cached user role
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _keyUserRole);
    } catch (e) {
      return null;
    }
  }

  /// Check if an access token exists
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored tokens securely upon logout
  Future<void> clear() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserRole);
      AppLogger.info('🔒 TokenVault wiped successfully on logout.');
    } catch (e, stack) {
      AppLogger.error('Failed to wipe TokenVault', error: e, stackTrace: stack);
    }
  }
}
