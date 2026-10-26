import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for Jotpot application.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static String _getEnv(String key, String fallback) {
    try {
      final val = dotenv.env[key];
      if (val != null && val.trim().isNotEmpty) {
        return val.trim();
      }
    } catch (_) {}
    return fallback;
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_WEB_API_KEY', 'AIzaSyCp_CgrAIObbmdpTF8Aq6jzSm0ZO2AThrk'),
    appId: _getEnv('FIREBASE_WEB_APP_ID', '1:687027102274:web:8ccc5669f6c0c8056083db'),
    messagingSenderId: _getEnv('FIREBASE_WEB_MESSAGING_SENDER_ID', '687027102274'),
    projectId: _getEnv('FIREBASE_WEB_PROJECT_ID', 'jotpot-d7e6b'),
    authDomain: _getEnv('FIREBASE_WEB_AUTH_DOMAIN', 'jotpot-d7e6b.firebaseapp.com'),
    storageBucket: _getEnv('FIREBASE_WEB_STORAGE_BUCKET', 'jotpot-d7e6b.firebasestorage.app'),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_ANDROID_API_KEY', 'AIzaSyBQkvZUVkF5bf2cGcEO8qAxJNGqogy_ajQ'),
    appId: _getEnv('FIREBASE_ANDROID_APP_ID', '1:687027102274:android:6b8f7c8cd9702ffe6083db'),
    messagingSenderId: _getEnv('FIREBASE_ANDROID_MESSAGING_SENDER_ID', '687027102274'),
    projectId: _getEnv('FIREBASE_ANDROID_PROJECT_ID', 'jotpot-d7e6b'),
    storageBucket: _getEnv('FIREBASE_ANDROID_STORAGE_BUCKET', 'jotpot-d7e6b.firebasestorage.app'),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_IOS_API_KEY', 'AIzaSyCp_CgrAIObbmdpTF8Aq6jzSm0ZO2AThrk'),
    appId: _getEnv('FIREBASE_IOS_APP_ID', '1:687027102274:web:8ccc5669f6c0c8056083db'),
    messagingSenderId: _getEnv('FIREBASE_IOS_MESSAGING_SENDER_ID', '687027102274'),
    projectId: _getEnv('FIREBASE_IOS_PROJECT_ID', 'jotpot-d7e6b'),
    storageBucket: _getEnv('FIREBASE_IOS_STORAGE_BUCKET', 'jotpot-d7e6b.firebasestorage.app'),
  );
}
