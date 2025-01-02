import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAiq-A4K4Hv5iTGgPG6HRJQKI1iGvJBLtM',
    appId: '1:133227637259:android:4bee366bc67e07f6e3b50e',
    messagingSenderId: '133227637259',
    projectId: 'swami-samartha-ent-dist',
    storageBucket: 'swami-samartha-ent-dist.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3TRAxLY8-zi_CoKUkSD6dDtxrpEWBvEY',
    appId: '1:133227637259:ios:69c20c069012e17ce3b50e',
    messagingSenderId: '133227637259',
    projectId: 'swami-samartha-ent-dist',
    storageBucket: 'swami-samartha-ent-dist.firebasestorage.app',
    iosBundleId: 'com.example.sssRetail',
  );
}
