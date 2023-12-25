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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              PrivacyPolicyItem(
                number: '1',
                content: 'Administratorem danych osobowych jest Wrocławska Akademia Biznesu.',
              ),
              PrivacyPolicyItem(
                number: '2',
                content: 'Dane osobowe są przetwarzane w celu obsługi aplikacji "Zami - Zamów mnie" - prostej aplikacji do zamawiania jedzenia fast food.',
              ),
              PrivacyPolicyItem(
                number: '3',
                content: 'Dane nie są udostępniane osobom trzecim i są przechowywane zgodnie z obowiązującymi przepisami prawa.',
              ),
              PrivacyPolicyItem(
                number: '4',
                content: 'Użytkownik ma prawo żądania dostępu, poprawiania, usuwania lub ograniczenia przetwarzania swoich danych osobowych.',
              ),
              PrivacyPolicyItem(
                number: '5',
                content: 'Aplikacja wykorzystuje pliki cookies w celu poprawy jakości usług.',
              ),
              PrivacyPolicyItem(
                number: '6',
                content: 'Administracja zastrzega sobie prawo do zmiany polityki prywatności w dowolnym czasie.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyItem extends StatelessWidget {
  final String number;
  final String content;

  const PrivacyPolicyItem({
    required this.number,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. $content',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
