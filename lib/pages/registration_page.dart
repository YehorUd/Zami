import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../RODO/privacy_policy_page.dart';
import '../RODO/terms_page.dart';
import 'security_utils.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_enterprise.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

// Strona rejestracji
class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kontrolery dla pól tekstowych
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  // Flagi do obsługi widoczności hasła, zgody, i reCAPTCHA
  bool _isPasswordVisible1 = false;
  bool _isPasswordVisible2 = false;
  bool _isAgreeChecked = false;
  bool _isRecaptchaChecked = false;

  // Obiekt reCAPTCHA
  final _recaptchaEnterprisePlugin = RecaptchaEnterprise();

  @override
  void initState() {
    super.initState();
    _initRecaptcha();
  }

  // Inicjalizacja reCAPTCHA
  void _initRecaptcha() async {
    String siteKey = '6Lc58DspAAAAAADqgbFlG4qFz76s236CUPxSB1r_';

    try {
      await RecaptchaEnterprise.initClient(siteKey, timeout: 10000);
    } catch (e) {
      print('Caught exception on init: $e');
    }
  }

  // Rejestracja użytkownika
  void _register() async {
    try {
      // Sprawdzenie zgody i reCAPTCHA
      if (!_isAgreeChecked || !_isRecaptchaChecked) {
        _showErrorDialog(
            'Błąd rejestracji',
            'Musisz zaakceptować warunki, politykę prywatności i potwierdzić, że nie jesteś robotem.');
        return;
      }

      // Generowanie soli i hashowanie hasła
      final salt = BCrypt.gensalt();
      final hashedPassword = hashPassword(_passwordController.text);

      // Sprawdzenie poprawności wprowadzonych danych
      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showErrorDialog(
            'Błąd rejestracji', 'Wprowadź wszystkie wymagane dane.');
        return;
      }

      // Sprawdzenie zgodności wprowadzonych haseł
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog('Błąd rejestracji',
            'Hasła nie są identyczne. Sprawdź wprowadzone dane i spróbuj ponownie.');
        return;
      }

      // Wykonanie reCAPTCHA
      bool recaptchaResult = await _executeRecaptcha();

      if (!recaptchaResult) {
        return;
      }

      // Rejestracja w Firebase
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: hashedPassword,
      );

      // Dodanie użytkownika do kolekcji Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          'hashedPassword': hashedPassword,
          'salt': salt,
        });

        // Powrót do poprzedniego ekranu po udanej rejestracji
        Navigator.pop(context);
      }
    } catch (e) {
      print('Firebase Error: $e');

      // Obsługa błędu podczas rejestracji
      _showErrorDialog('Błąd rejestracji',
          'Wystąpił błąd podczas rejestracji. Sprawdź swoje dane i spróbuj ponownie.');
    }
  }

  // Wykonanie reCAPTCHA
  Future<bool> _executeRecaptcha() async {
    try {
      String result = await RecaptchaEnterprise.execute(
          RecaptchaAction.LOGIN(), timeout: 10000);

      if (result.isNotEmpty) {
        setState(() {
          _isRecaptchaChecked = true;
        });
        return true;
      } else {
        _showRecaptchaErrorDialog();
        return false;
      }
    } catch (e) {
      print('Caught exception on execute: $e');
      _showRecaptchaErrorDialog();
      return false;
    }
  }

  // Wyświetlenie komunikatu o błędzie reCAPTCHA
  void _showRecaptchaErrorDialog() {
    _showErrorDialog('Błąd weryfikacji reCAPTCHA',
        'Weryfikacja reCAPTCHA nie powiodła się. Spróbuj ponownie.');
  }

  // Wyświetlenie ogólnego komunikatu o błędzie
  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
              // Pole tekstowe dla adresu email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 12.0),
              // Pole tekstowe dla hasła
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible1,
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible1 ? Icons.visibility : Icons
                        .visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible1 = !_isPasswordVisible1;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              // Pole tekstowe do potwierdzenia hasła
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible2,
                decoration: InputDecoration(
                  labelText: 'Potwierdź hasło',
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible2 ? Icons.visibility : Icons
                        .visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible2 = !_isPasswordVisible2;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              // Checkbox i linki do warunków i polityki prywatności
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
                    // Link do warunków
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
                    // Link do polityki prywatności
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
              // Checkbox do potwierdzenia reCAPTCHA
              ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: Checkbox(
                  value: _isRecaptchaChecked,
                  onChanged: (bool? value) {
                    if (_isAgreeChecked) {
                      setState(() {
                        _isRecaptchaChecked = value!;
                      });
                    }
                  },
                ),
                title: Text('Nie jestem robotem'),
              ),
              SizedBox(height: 24.0),
              // Przycisk do zarejestrowania
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

  // Nawigacja do strony z warunkami
  void _navigateToTermsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsPage()),
    );
  }

  // Nawigacja do strony z polityką prywatności
  void _navigateToPrivacyPolicyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
    );
  }
}
