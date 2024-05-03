// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgfEGKADoZI0xQ5eVElywgo9PlNy2Tqdg',
    appId: '1:45287716611:web:3695ef79df344e0bc69b36',
    messagingSenderId: '45287716611',
    projectId: 'app1-c8763',
    authDomain: 'app1-c8763.firebaseapp.com',
    storageBucket: 'app1-c8763.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhwftpBDZMMYR9UAHrZXokO_X254anFKU',
    appId: '1:45287716611:android:050fad665e4c2119c69b36',
    messagingSenderId: '45287716611',
    projectId: 'app1-c8763',
    storageBucket: 'app1-c8763.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB04zLfWh3VHUSCWkhwsA22uf0FccJL8g0',
    appId: '1:45287716611:ios:fd724e5a99d0216cc69b36',
    messagingSenderId: '45287716611',
    projectId: 'app1-c8763',
    storageBucket: 'app1-c8763.appspot.com',
    iosBundleId: 'com.example.app1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB04zLfWh3VHUSCWkhwsA22uf0FccJL8g0',
    appId: '1:45287716611:ios:fd724e5a99d0216cc69b36',
    messagingSenderId: '45287716611',
    projectId: 'app1-c8763',
    storageBucket: 'app1-c8763.appspot.com',
    iosBundleId: 'com.example.app1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDgfEGKADoZI0xQ5eVElywgo9PlNy2Tqdg',
    appId: '1:45287716611:web:27a2953f51c7bf6ac69b36',
    messagingSenderId: '45287716611',
    projectId: 'app1-c8763',
    authDomain: 'app1-c8763.firebaseapp.com',
    storageBucket: 'app1-c8763.appspot.com',
  );
}
