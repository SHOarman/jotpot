import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCp_CgrAIObbmdpTF8Aq6jzSm0ZO2AThrk',
    appId: '1:687027102274:web:8ccc5669f6c0c8056083db',
    messagingSenderId: '687027102274',
    projectId: 'jotpot-d7e6b',
    authDomain: 'jotpot-d7e6b.firebaseapp.com',
    storageBucket: 'jotpot-d7e6b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQkvZUVkF5bf2cGcEO8qAxJNGqogy_ajQ',
    appId: '1:687027102274:android:6b8f7c8cd9702ffe6083db',
    messagingSenderId: '687027102274',
    projectId: 'jotpot-d7e6b',
    storageBucket: 'jotpot-d7e6b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCp_CgrAIObbmdpTF8Aq6jzSm0ZO2AThrk',
    appId: '1:687027102274:web:8ccc5669f6c0c8056083db',
    messagingSenderId: '687027102274',
    projectId: 'jotpot-d7e6b',
    storageBucket: 'jotpot-d7e6b.firebasestorage.app',
  );
}
