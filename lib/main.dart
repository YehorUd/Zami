import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zami/theme.dart';
import 'pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;

void main() async {
  // Zapewnienie inicjalizacji wiązań dla Fluttera
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicjalizacja Firebase, obsługa różnych konfiguracji dla webu i innych platform
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBCUGufWjmbD3W1DMnSbPcpOYZ6hjiRnS4",
          authDomain: "zami-1082f.firebaseapp.com",
          databaseURL: "https://zami-1082f-default-rtdb.firebaseio.com",
          projectId: "zami-1082f",
          storageBucket: "zami-1082f.appspot.com",
          messagingSenderId: "618640597187",
          appId: "1:618640597187:web:a8532c866e7a4ef65ec276",
          measurementId: "G-WFXD0QP76D",
        ),
      );
    } else {
      // Inicjalizacja Firebase dla innych platform
      await Firebase.initializeApp();
    }

    // Uruchomienie aplikacji Flutter
    runApp(const MyApp());
  } catch (e) {
    // Obsługa błędów podczas inicjalizacji Firebase
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Konfiguracja głównej aplikacji Flutter
    return MaterialApp(
      title: 'Zami',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: LoginPage(),
    );
  }
}
