import 'package:flutter/material.dart';
import 'package:zami/models/invoice.dart';
import 'package:zami/pages/cart_page.dart'; // Dodaj import

class OrderFormPage extends StatefulWidget {
  @override
  _OrderFormPageState createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Wrocław');
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formularz zamówienia'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wymagane informacje dla płatności:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Imię i nazwisko'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'To pole jest wymagane';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adres'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'To pole jest wymagane';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: 'Kod pocztowy',
                hintText: '00-000',
              ),
              keyboardType: TextInputType.number,
              maxLength: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'To pole jest wymagane';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _nipController,
              decoration: InputDecoration(labelText: 'NIP (opcjonalnie)'),
              keyboardType: TextInputType.number,
              maxLength: 10,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Sprawdź poprawność pól formularza
                if (_validateForm()) {
                  // Utwórz obiekt Customer z wprowadzonymi informacjami
                  Customer customer = Customer(
                    name: _nameController.text,
                    address: _addressController.text,
                    city: 'Wrocław',
                    postalCode: _postalCodeController.text,
                    nip: _nipController.text,
                  );

                  // Prześlij obiekt customer do poprzedniego ekranu
                  Navigator.pop(context, OrderFormResult(customer: customer));
                }
              },
              child: Text('Dalej'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    // Dodaj logikę walidacji
    // Na przykład, możesz sprawdzić, czy wymagane pola nie są puste
    return _nameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _postalCodeController.text.isNotEmpty;
  }
}

class OrderFormResult {
  final Customer customer;

  OrderFormResult({required this.customer});
}