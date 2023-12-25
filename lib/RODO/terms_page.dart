import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warunki'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Warunki korzystania',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TermsItem(
                number: '1',
                content: 'Niniejszy regulamin określa zasady korzystania z usług dostępnych w aplikacji "Zami - Zamów mnie".',
              ),
              TermsItem(
                number: '2',
                content: 'Użytkownik jest zobowiązany do przestrzegania postanowień niniejszego regulaminu.',
              ),
              TermsItem(
                number: '3',
                content: 'Aplikacja "Zami - Zamów mnie" służy do składania zamówień na jedzenie fast food.',
              ),
              TermsItem(
                number: '4',
                content: 'Zabrania się przesyłania treści obraźliwych lub niezgodnych z obowiązującym prawem.',
              ),
              TermsItem(
                number: '5',
                content: 'Administracja zastrzega sobie prawo do zablokowania dostępu użytkownika w przypadku naruszenia regulaminu.',
              ),
              TermsItem(
                number: '6',
                content: 'Aplikacja jest projektem dyplomowym studenta Wrocławskiej Akademii Biznesu na kierunku informatyka.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsItem extends StatelessWidget {
  final String number;
  final String content;

  const TermsItem({
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
