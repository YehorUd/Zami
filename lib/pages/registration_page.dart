import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../RODO/privacy_policy_page.dart';
import '../RODO/terms_page.dart';
import 'security_utils.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_enterprise.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

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
  bool _isRecaptchaChecked = false;

  final _recaptchaEnterprisePlugin = RecaptchaEnterprise();

  @override
  void initState() {
    super.initState();
    _initRecaptcha();
  }

  void _initRecaptcha() async {
    String siteKey = '6Lc58DspAAAAAADqgbFlG4qFz76s236CUPxSB1r_';

    try {
      await RecaptchaEnterprise.initClient(siteKey, timeout: 10000);
    } catch (e) {
      print('Caught exception on init: $e');
    }
  }

  void _register() async {
    try {
      if (!_isAgreeChecked || !_isRecaptchaChecked) {
        _showErrorDialog(
            'Błąd rejestracji',
            'Musisz zaakceptować warunki, politykę prywatności i potwierdzić, że nie jesteś robotem.');
        return;
      }

      final salt = BCrypt.gensalt();
      final hashedPassword = hashPassword(_passwordController.text);

      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showErrorDialog(
            'Błąd rejestracji', 'Wprowadź wszystkie wymagane dane.');
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog('Błąd rejestracji',
            'Hasła nie są identyczne. Sprawdź wprowadzone dane i spróbuj ponownie.');
        return;
      }

      bool recaptchaResult = await _executeRecaptcha();

      if (!recaptchaResult) {
        return;
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
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
      print('Firebase Error: $e');

      _showErrorDialog('Błąd rejestracji',
          'Wystąpił błąd podczas rejestracji. Sprawdź swoje dane i spróbuj ponownie.');
    }
  }

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

  void _showRecaptchaErrorDialog() {
    _showErrorDialog('Błąd weryfikacji reCAPTCHA',
        'Weryfikacja reCAPTCHA nie powiodła się. Spróbuj ponownie.');
  }

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

  void _navigateToTermsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsPage()),
    );
  }

  void _navigateToPrivacyPolicyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
    );
  }
}
