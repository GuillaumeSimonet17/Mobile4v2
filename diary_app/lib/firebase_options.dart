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
    apiKey: 'AIzaSyBnXXUqU61Y4suOzXgxOd5XHNOshg_5JMM',
    appId: '1:1042215891505:web:6f979f2a92e0c739c15b10',
    messagingSenderId: '1042215891505',
    projectId: 'diary-app-1e5d2',
    authDomain: 'diary-app-1e5d2.firebaseapp.com',
    storageBucket: 'diary-app-1e5d2.firebasestorage.app',
    measurementId: 'G-5LSVZJD1VV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtwSMVf2FU6RiQAKqWhsqtToeTBscO_jc',
    appId: '1:1042215891505:android:28adee1464f6a07ac15b10',
    messagingSenderId: '1042215891505',
    projectId: 'diary-app-1e5d2',
    storageBucket: 'diary-app-1e5d2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6PTO0i7IEXwwiHswAPQJv-oEV5hVuBpY',
    appId: '1:1042215891505:ios:69cf090ba0c17e2ac15b10',
    messagingSenderId: '1042215891505',
    projectId: 'diary-app-1e5d2',
    storageBucket: 'diary-app-1e5d2.firebasestorage.app',
    androidClientId: '1042215891505-k35ocfn8vbuiha7o2c9ns6t210ig0sut.apps.googleusercontent.com',
    iosClientId: '1042215891505-040sg39mdf4qali8ahei95de2uqpcm2h.apps.googleusercontent.com',
    iosBundleId: 'com.example.diaryApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB6PTO0i7IEXwwiHswAPQJv-oEV5hVuBpY',
    appId: '1:1042215891505:ios:69cf090ba0c17e2ac15b10',
    messagingSenderId: '1042215891505',
    projectId: 'diary-app-1e5d2',
    storageBucket: 'diary-app-1e5d2.firebasestorage.app',
    androidClientId: '1042215891505-k35ocfn8vbuiha7o2c9ns6t210ig0sut.apps.googleusercontent.com',
    iosClientId: '1042215891505-040sg39mdf4qali8ahei95de2uqpcm2h.apps.googleusercontent.com',
    iosBundleId: 'com.example.diaryApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBnXXUqU61Y4suOzXgxOd5XHNOshg_5JMM',
    appId: '1:1042215891505:web:6f979f2a92e0c739c15b10',
    messagingSenderId: '1042215891505',
    projectId: 'diary-app-1e5d2',
    authDomain: 'diary-app-1e5d2.firebaseapp.com',
    storageBucket: 'diary-app-1e5d2.firebasestorage.app',
    measurementId: 'G-5LSVZJD1VV',
  );

}