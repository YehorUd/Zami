import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        // Zarejestrowano pomyślnie
        // Zapisz dane użytkownika do Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          'password': _passwordController.text,
        });

        // Przejdź do innej strony lub wykonaj inne działania
        Navigator.pop(context); // Powrót do strony logowania po zarejestrowaniu
      }
    } catch (e) {
      // Obsłuż błędy rejestracji
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
                    color: Colors.black, // Zmieniono kolor tekstu na czarny
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rejestracja'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Hasło',
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
    );
  }
}
