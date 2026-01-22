import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'env_config.dart';

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    authDomain: EnvConfig.firebaseAuthDomain,
    projectId: EnvConfig.firebaseProjectId,
    storageBucket: EnvConfig.firebaseStorageBucket,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    appId: EnvConfig.firebaseAppId,
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    appId: EnvConfig.firebaseAppId,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    storageBucket: EnvConfig.firebaseStorageBucket,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    appId: EnvConfig.firebaseAppId,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    storageBucket: EnvConfig.firebaseStorageBucket,
    iosBundleId: 'com.aplus.fixsy.fixxsyFlutter',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    appId: EnvConfig.firebaseAppId,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    storageBucket: EnvConfig.firebaseStorageBucket,
    iosBundleId: 'com.aplus.fixsy.fixxsyFlutter',
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    appId: EnvConfig.firebaseAppId,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    storageBucket: EnvConfig.firebaseStorageBucket,
  );
}
