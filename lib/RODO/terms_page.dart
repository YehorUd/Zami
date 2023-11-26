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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '1. Niniejszy regulamin określa zasady korzystania z usług dostępnych w aplikacji "Zami - Zamów mnie".',
              ),
              Text(
                '2. Użytkownik jest zobowiązany do przestrzegania postanowień niniejszego regulaminu.',
              ),
              Text(
                '3. Aplikacja "Zami - Zamów mnie" służy do składania zamówień na jedzenie fast food.',
              ),
              Text(
                '4. Zabrania się przesyłania treści obraźliwych lub niezgodnych z obowiązującym prawem.',
              ),
              Text(
                '5. Administracja zastrzega sobie prawo do zablokowania dostępu użytkownika w przypadku naruszenia regulaminu.',
              ),
              Text(
                '6. Aplikacja jest projektem dyplomowym studenta Wrocławskiej Akademii Biznesu na kierunku informatyka.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
