import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

// Replace this file by running:
// flutterfire configure --platforms=web,android,ios
//
// The values below are placeholders so the workshop app can be analyzed and
// built before the instructor connects the real Firebase project.
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
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for web, Android, and iOS.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA5iixvUgFav4KPYxqzXT-UHp5JDf9lZ_U',
    appId: '1:86608508201:web:3e9a46ff21d8963792f338',
    messagingSenderId: '86608508201',
    projectId: 'flutter-workshops',
    authDomain: 'flutter-workshops.firebaseapp.com',
    storageBucket: 'flutter-workshops.firebasestorage.app',
    measurementId: 'G-B9TRW5NL4M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZdlyeuUd9dS9Z6VGzoPuKAXOBBBP5HDE',
    appId: '1:86608508201:android:2fb7fc68ccfd361d92f338',
    messagingSenderId: '86608508201',
    projectId: 'flutter-workshops',
    storageBucket: 'flutter-workshops.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVAKra6dxDcWRxyiSAeQFi3GtQmwIJq6A',
    appId: '1:86608508201:ios:f56424e0911ef00c92f338',
    messagingSenderId: '86608508201',
    projectId: 'flutter-workshops',
    storageBucket: 'flutter-workshops.firebasestorage.app',
    iosBundleId: 'com.example.miniInstagram',
  );
}
