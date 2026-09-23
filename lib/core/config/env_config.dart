import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager
/// Loads all environment variables from .env file
class EnvConfig {
  static String _getEnv(String key) {
    if (!dotenv.isInitialized) return '';
    return dotenv.env[key] ?? '';
  }

  // Firebase Configuration
  static String get firebaseApiKey => _getEnv('FIREBASE_API_KEY');
  static String get firebaseAuthDomain => _getEnv('FIREBASE_AUTH_DOMAIN');
  static String get firebaseProjectId => _getEnv('FIREBASE_PROJECT_ID');
  static String get firebaseStorageBucket => _getEnv('FIREBASE_STORAGE_BUCKET');
  static String get firebaseMessagingSenderId => _getEnv('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseAppId => _getEnv('FIREBASE_APP_ID');

  // AI Services
  static String get groqApiKey => _getEnv('GROQ_API_KEY');
  static String get geminiApiKey => _getEnv('GEMINI_API_KEY');

  /// Initialize environment configuration
  /// Should be called in main() before runApp()
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
}
