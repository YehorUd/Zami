import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zami/theme.dart';
import 'pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
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
      await Firebase.initializeApp();
    }

    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: appTheme,
      home: LoginPage(),
    );
  }
}
