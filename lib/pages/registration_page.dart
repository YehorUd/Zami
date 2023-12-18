import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security_utils.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:zami/RODO/terms_page.dart';
import 'package:zami/RODO/privacy_policy_page.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible1 = false;
  bool _isPasswordVisible2 = false;
  bool _isAgreeChecked = false;


  void _register() async {
    try {
      if (!_isAgreeChecked) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Błąd rejestracji'),
              content: Text('Musisz zaakceptować warunki i politykę prywatności.'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      final salt = BCrypt.gensalt();
      final hashedPassword = hashPassword(_passwordController.text);

      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        // Pola e-maila, hasła i potwierdzenia hasła nie mogą być puste
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Błąd rejestracji'),
              content: Text('Wprowadź wszystkie wymagane dane.'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        // Hasła nie są identyczne
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Błąd rejestracji'),
              content: Text('Hasła nie są identyczne. Sprawdź wprowadzone dane i spróbuj ponownie.'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: hashedPassword,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          'hashedPassword': hashedPassword,
          'salt': salt,
        });

        Navigator.pop(context);
      }
    } catch (e) {
      // Wypisz błąd Firebase w konsoli
      print('Firebase Error: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Błąd rejestracji'),
            content: Text('Wystąpił błąd podczas rejestracji. Sprawdź swoje dane i spróbuj ponownie.'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.black,
                  ),
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
  void _navigateToTermsPage() {
    // Tutaj nawigacja do strony z warunkami
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsPage()),
    );
  }

  void _navigateToPrivacyPolicyPage() {
    // Tutaj nawigacja do strony z polityką prywatności
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rejestracja'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible1,
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible1 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible1 = !_isPasswordVisible1;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible2,
                decoration: InputDecoration(
                  labelText: 'Potwierdź hasło',
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible2 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible2 = !_isPasswordVisible2;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: Checkbox(
                  value: _isAgreeChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAgreeChecked = value!;
                    });
                  },
                ),
                title: Text('Zgadzam się z '),
                subtitle: Row(
                  children: [
                    GestureDetector(
                      onTap: _navigateToTermsPage,
                      child: Text(
                        'warunkami',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(' i '),
                    GestureDetector(
                      onTap: _navigateToPrivacyPolicyPage,
                      child: Text(
                        'polityką prywatności',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _register,
                child: Text('Zarejestruj się'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}