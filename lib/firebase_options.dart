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
    apiKey: 'AIzaSyCWHtP8SgLqVzUMu1I4QxI6laygHBeM4TI',
    appId: '1:130822511337:web:2d437ca1530cb0ba6b2e78',
    messagingSenderId: '130822511337',
    projectId: 'epic-sax-gandalf-infinite',
    authDomain: 'epic-sax-gandalf-infinite.firebaseapp.com',
    databaseURL: 'https://epic-sax-gandalf-infinite.firebaseio.com',
    storageBucket: 'epic-sax-gandalf-infinite.firebasestorage.app',
    measurementId: 'G-BVCGZ9NDSV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmrHvGkLn5B91Kr2vTBj8VO2uZb4KqzW0',
    appId: '1:130822511337:android:92fc13918490c4d56b2e78',
    messagingSenderId: '130822511337',
    projectId: 'epic-sax-gandalf-infinite',
    databaseURL: 'https://epic-sax-gandalf-infinite.firebaseio.com',
    storageBucket: 'epic-sax-gandalf-infinite.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDEcFRJLsPHskgAm21PejPyvSW1S4oJJs',
    appId: '1:130822511337:ios:f1c19bfcc5f0d0776b2e78',
    messagingSenderId: '130822511337',
    projectId: 'epic-sax-gandalf-infinite',
    databaseURL: 'https://epic-sax-gandalf-infinite.firebaseio.com',
    storageBucket: 'epic-sax-gandalf-infinite.firebasestorage.app',
    androidClientId: '130822511337-2prj3l1ut9vdtgm7du9lcdn3r14uprel.apps.googleusercontent.com',
    iosBundleId: 'com.example.gandalf',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCDEcFRJLsPHskgAm21PejPyvSW1S4oJJs',
    appId: '1:130822511337:ios:f1c19bfcc5f0d0776b2e78',
    messagingSenderId: '130822511337',
    projectId: 'epic-sax-gandalf-infinite',
    databaseURL: 'https://epic-sax-gandalf-infinite.firebaseio.com',
    storageBucket: 'epic-sax-gandalf-infinite.firebasestorage.app',
    androidClientId:
        '130822511337-2prj3l1ut9vdtgm7du9lcdn3r14uprel.apps.googleusercontent.com',
    iosBundleId: 'com.example.gandalf',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCWHtP8SgLqVzUMu1I4QxI6laygHBeM4TI',
    appId: '1:130822511337:web:2ffab151968b9eb36b2e78',
    messagingSenderId: '130822511337',
    projectId: 'epic-sax-gandalf-infinite',
    authDomain: 'epic-sax-gandalf-infinite.firebaseapp.com',
    databaseURL: 'https://epic-sax-gandalf-infinite.firebaseio.com',
    storageBucket: 'epic-sax-gandalf-infinite.firebasestorage.app',
    measurementId: 'G-FNTB6W4T3X',
  );
}
