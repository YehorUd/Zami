import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Polityka Prywatności'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Polityka prywatności',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '1. Administratorem danych osobowych jest Wrocławska Akademia Biznesu.',
              ),
              Text(
                '2. Dane osobowe są przetwarzane w celu obsługi aplikacji "Zami - Zamów mnie" - prostej aplikacji do zamawiania jedzenia fast food.',
              ),
              Text(
                '3. Dane nie są udostępniane osobom trzecim i są przechowywane zgodnie z obowiązującymi przepisami prawa.',
              ),
              Text(
                '4. Użytkownik ma prawo żądania dostępu, poprawiania, usuwania lub ograniczenia przetwarzania swoich danych osobowych.',
              ),
              Text(
                '5. Aplikacja wykorzystuje pliki cookies w celu poprawy jakości usług.',
              ),
              Text(
                '6. Administracja zastrzega sobie prawo do zmiany polityki prywatności w dowolnym czasie.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
