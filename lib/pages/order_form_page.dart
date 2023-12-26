import 'package:flutter/material.dart';
import 'package:zami/models/invoice.dart';

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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formularz zamówienia'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'Kod pocztowy',
                    hintText: '00-000',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6, // Zwiększ maksymalną długość do 6 (np. 00-000)
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
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate the form
                      if (_formKey.currentState?.validate() ?? false) {
                        // Create a Customer object with the entered information
                        Customer customer = Customer(
                          name: _nameController.text,
                          address: _addressController.text,
                          city: 'Wrocław',
                          postalCode: _postalCodeController.text,
                          nip: _nipController.text.isEmpty ? '—' : _nipController.text,
                        );

                        // Send the customer object to the previous screen
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
    );
  }
}

class OrderFormResult {
  final Customer customer;

  OrderFormResult({required this.customer});
}
