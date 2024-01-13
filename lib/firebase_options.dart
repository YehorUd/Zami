// Plik wygenerowany przy użyciu FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

// Klasa zawierająca domyślne opcje Firebase dla różnych platform.
class DefaultFirebaseOptions {
  // Zwraca opcje Firebase odpowiadające bieżącej platformie.
  static FirebaseOptions get currentPlatform {
    // Dla platformy webowej używane są opcje 'web'.
    if (kIsWeb) {
      return web;
    }

    // Sprawdzamy platformę docelową i zwracamy odpowiednie opcje.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions nie zostały skonfigurowane dla iOS - '
              'możesz to ponownie skonfigurować, uruchamiając ponownie FlutterFire CLI.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions nie zostały skonfigurowane dla macOS - '
              'możesz to ponownie skonfigurować, uruchamiając ponownie FlutterFire CLI.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions nie zostały skonfigurowane dla Windows - '
              'możesz to ponownie skonfigurować, uruchamiając ponownie FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions nie zostały skonfigurowane dla Linux - '
              'możesz to ponownie skonfigurować, uruchamiając ponownie FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions nie są obsługiwane dla tej platformy.',
        );
    }
  }

  // Opcje Firebase dla platformy webowej.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBCUGufWjmbD3W1DMnSbPcpOYZ6hjiRnS4',
    appId: '1:618640597187:web:a8532c866e7a4ef65ec276',
    messagingSenderId: '618640597187',
    projectId: 'zami-1082f',
    authDomain: 'zami-1082f.firebaseapp.com',
    databaseURL: 'https://zami-1082f-default-rtdb.firebaseio.com',
    storageBucket: 'zami-1082f.appspot.com',
    measurementId: 'G-WFXD0QP76D',
  );

  // Opcje Firebase dla platformy Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCrYrQaufd7PoDDgtD5S1yp0xskZBkB0oo',
    appId: '1:618640597187:android:554835007a2a6bfc5ec276',
    messagingSenderId: '618640597187',
    projectId: 'zami-1082f',
    databaseURL: 'https://zami-1082f-default-rtdb.firebaseio.com',
    storageBucket: 'zami-1082f.appspot.com',
  );
}
