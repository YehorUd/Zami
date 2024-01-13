// Strona do logowania użytkownika, wykorzystująca Firebase Auth i Google Sign-In.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'main_page.dart';
import 'registration_page.dart';
import 'security_utils.dart';  // Utils do zabezpieczeń, np. funkcja do weryfikacji hasła
import 'package:bcrypt/bcrypt.dart';  // Biblioteka do obsługi funkcji hashowania hasła

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Kontrolery dla pól tekstowych
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instancje Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Flaga do ukrywania/odsłaniania hasła
  bool _isPasswordVisible = false;

  // Logowanie za pomocą e-mail i hasła
  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      // Pobieranie danych użytkownika z bazy Firestore
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        final hashedPassword = userData['hashedPassword'];

        // Weryfikacja hasła
        if (verifyPassword(_passwordController.text, hashedPassword)) {
          // Przejście do strony głównej po udanym logowaniu
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
          return;
        }
      }

      // Wyświetlanie alertu w przypadku nieudanego logowania
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Błąd logowania'),
            content: const Text(
              'Wystąpił błąd podczas logowania. Sprawdź swoje dane logowania i spróbuj ponownie.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Obsługa błędów związanych z Firebase
      print('Firebase Error: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Błąd logowania'),
            content: Text(
              'Wystąpił błąd podczas logowania. Sprawdź swoje dane logowania i spróbuj ponownie.\nError: $e',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Logowanie za pomocą konta Google
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Pobieranie danych o użytkowniku z Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Tworzenie credential dla Google Sign-In
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Logowanie do Firebase za pomocą credential
        await _auth.signInWithCredential(credential);

        // Przejście do strony głównej po udanym logowaniu
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } catch (e) {
      // Obsługa błędów związanych z Google Sign-In
      print('Google Sign-In Error: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Błąd logowania'),
            content: const Text(
              'Wystąpił błąd podczas logowania przez konto Google. Spróbuj ponownie.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Nawigacja do strony rejestracji
  void _navigateToRegistrationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logowanie'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pole tekstowe dla e-maila
                Container(
                  width: 300,
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Pole tekstowe dla hasła
                Container(
                  width: 300,
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Hasło',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                  ),
                ),

                const SizedBox(height: 16.0),
                // Przycisk do logowania za pomocą e-maila i hasła
                ElevatedButton(
                  onPressed: () => _signInWithEmailAndPassword(context),
                  child: const Text('Zaloguj się'),
                ),
                const SizedBox(height: 16.0),
                // Przycisk do logowania za pomocą konta Google
                SignInButton(
                  Buttons.Google,
                  text: "Zaloguj się przez Google",
                  onPressed: () => _signInWithGoogle(context),
                ),
                const SizedBox(height: 16.0),
                // Przycisk do nawigacji do strony rejestracji
                SignInButtonBuilder(
                  text: 'Zarejestruj się przez E-mail',
                  icon: Icons.email,
                  onPressed: () => _navigateToRegistrationPage(context),
                  backgroundColor: Colors.blueGrey[700]!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
