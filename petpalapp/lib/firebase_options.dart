// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBauyWzTlGufn0wjmsFPKeb5TGCB0RSusw',
    appId: '1:922997148557:web:0f6b1589195a7af45bcbc4',
    messagingSenderId: '922997148557',
    projectId: 'petpal-19593',
    authDomain: 'petpal-19593.firebaseapp.com',
    storageBucket: 'petpal-19593.appspot.com',
    measurementId: 'G-7VVR1Y2BQP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAaA7k4FHQNx5o5LoDgUIsiy_2zqIOEZb0',
    appId: '1:922997148557:android:0d08e84ff83e2a005bcbc4',
    messagingSenderId: '922997148557',
    projectId: 'petpal-19593',
    storageBucket: 'petpal-19593.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3xlzmOjSHoZ4HyCC2oK6a_WCyO22hKXM',
    appId: '1:922997148557:ios:fcaa81fe19a3ff2e5bcbc4',
    messagingSenderId: '922997148557',
    projectId: 'petpal-19593',
    storageBucket: 'petpal-19593.appspot.com',
    iosBundleId: 'com.example.petpalapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC3xlzmOjSHoZ4HyCC2oK6a_WCyO22hKXM',
    appId: '1:922997148557:ios:0062ab2a897e00e55bcbc4',
    messagingSenderId: '922997148557',
    projectId: 'petpal-19593',
    storageBucket: 'petpal-19593.appspot.com',
    iosBundleId: 'com.example.petpalapp.RunnerTests',
  );
}
