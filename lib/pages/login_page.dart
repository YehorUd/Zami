import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'main_page.dart';
import 'registration_page.dart';
import 'security_utils.dart';
import 'package:bcrypt/bcrypt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isPasswordVisible = false;

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        final hashedPassword = userData['hashedPassword'];

        if (verifyPassword(_passwordController.text, hashedPassword)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
          return;
        }
      }

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


  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } catch (e) {
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
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
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

                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _signInWithEmailAndPassword(context),
                  child: const Text('Zaloguj się'),
                ),
                const SizedBox(height: 16.0),
                SignInButton(
                  Buttons.Google,
                  text: "Zaloguj się przez Google",
                  onPressed: () => _signInWithGoogle(context),
                ),
                const SizedBox(height: 16.0),
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
