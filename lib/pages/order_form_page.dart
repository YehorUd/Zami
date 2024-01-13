import 'package:flutter/material.dart';
import 'package:zami/models/invoice.dart';

// Strona zawierająca formularz zamówienia
class OrderFormPage extends StatefulWidget {
  @override
  _OrderFormPageState createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  // Kontrolery pól tekstowych
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Wrocław');
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();

  // Klucz formularza do walidacji
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formularz zamówienia'),
      ),
      body: Center(
        child: Container(
          width: 400,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Wymagane informacje dla płatności:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 32.0),
                  Center(
                    child: Container(
                      width: 300,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pole tekstowe na imię i nazwisko
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Imię i nazwisko',
                                hintText: 'Imię Nazwisko',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'To pole jest wymagane';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            // Pole tekstowe na adres
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Adres',
                                hintText: 'Przykładowa 10/1A',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'To pole jest wymagane';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            // Pole tekstowe na kod pocztowy
                            TextFormField(
                              controller: _postalCodeController,
                              decoration: InputDecoration(
                                labelText: 'Kod pocztowy',
                                hintText: '00-000',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              onChanged: (value) {
                                if (value.length == 2) {
                                  _postalCodeController.text = '$value-';
                                  _postalCodeController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _postalCodeController.text.length),
                                  );
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'To pole jest wymagane';
                                } else if (!RegExp(r'^\d{2}-\d{3}$').hasMatch(value)) {
                                  return 'Podaj poprawny kod pocztowy w formacie XX-XXX';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            // Pole tekstowe na NIP (opcjonalne)
                            TextFormField(
                              controller: _nipController,
                              decoration: InputDecoration(
                                labelText: 'NIP (opcjonalnie)',
                                hintText: '0123456789',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                            ),
                            SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Przycisk do przejścia dalej po poprawnej walidacji formularza
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate the form
                        if (_formKey.currentState?.validate() ?? false) {
                          // Utworzenie obiektu Customer na podstawie wprowadzonych danych
                          Customer customer = Customer(
                            name: _nameController.text,
                            address: _addressController.text,
                            city: 'Wrocław',
                            postalCode: _postalCodeController.text,
                            nip: _nipController.text.isEmpty ? '—' : _nipController.text,
                          );

                          // Powrót z wynikiem do poprzedniego ekranu
                          Navigator.pop(context, OrderFormResult(customer: customer));
                        }
                      },
                      child: Text('Dalej'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Klasa przechowująca wynik formularza
class OrderFormResult {
  final Customer customer;

  OrderFormResult({required this.customer});
}
