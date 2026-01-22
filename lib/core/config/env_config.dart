import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager
/// Loads all environment variables from .env file
class EnvConfig {
  // Firebase Configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // AI Services
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Initialize environment configuration
  /// Should be called in main() before runApp()
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
}
