// Strona koszyka, gdzie użytkownik może przeglądać, usuwać produkty i dokonywać płatności

// Importowanie niezbędnych pakietów i bibliotek
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:zami/models/invoice.dart';
import 'package:zami/helper/pdf_api.dart';
import 'dart:io';
import 'package:zami/pages/my_invoices_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zami/pages/order_form_page.dart';
import 'package:zami/models/cart_item.dart';

// Klasa reprezentująca stronę koszyka
class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = false; // Zmienna informująca o tym, czy trwa ładowanie
  OrderFormResult? orderFormResult; // Wynik formularza zamówienia

  // Funkcja generująca elementy płatności
  List<PaymentItem> get paymentItems {
    List<PaymentItem> items = [];

    double totalAmount = calculateTotalPrice(); // Obliczamy łączną kwotę

    // Dodajemy element płatności do listy
    items.add(
      PaymentItem(
        amount: totalAmount.toStringAsFixed(2),
        label: 'Suma',
        status: PaymentItemStatus.final_price,
      ),
    );

    return items;
  }

  // Funkcja zwracająca konfigurację płatności
  Future<PaymentConfiguration> paymentConfiguration() async {
    return PaymentConfiguration.fromAsset('json/google_pay_config.json');
  }

  // Obsługa wyniku płatności za pomocą Google Pay
  void onGooglePayResult(dynamic paymentResult, OrderFormResult orderFormResult) {

    // Wypisujemy informacje o wyniku płatności w konsoli debugowania
    debugPrint('Payment Result: $paymentResult');
    debugPrint('Complete Payment Result: ${paymentResult.toString()}');

    // Sprawdzamy, czy płatność zakończyła się sukcesem
    if (paymentResult != null && paymentResult['error'] == null) {
      _completePayment(orderFormResult: orderFormResult, paymentMethod: 'Google Pay');  // Kompletna obsługa płatności
    } else if (paymentResult != null && paymentResult['status'] == 'CANCELED') {

      // Obsługa anulowanej płatności
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment canceled by user')),
      );
      setState(() {
        _isLoading = false;
      });
    } else {
      debugPrint('Google Pay Error: ${paymentResult['status']}');  // Obsługa błędu płatności

      if (paymentResult != null && paymentResult['error'] != null) {
        final dynamic errorInfo = paymentResult['error'];
        debugPrint('Error Code: ${errorInfo['code']}');
        debugPrint('Error Message: ${errorInfo['message']}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed. Please try again.')),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Funkcja usuwająca element z koszyka
  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
      if (widget.cartItems.isEmpty) {
        Navigator.pop(context, widget.cartItems);
      }
    });
  }

  // Kontrolery do wprowadzania danych karty kredytowej
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();

  // Funkcja wyświetlająca okno dialogowe z danymi karty kredytowej
  void _showCardDetailsDialog(OrderFormResult orderFormResult) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Podaj dane karty'),
          content: Column(
            children: [
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(labelText: 'Numer karty (16 cyfr)'),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 16) {
                    return 'Podaj poprawny numer karty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: InputDecoration(labelText: 'Data ważności (YYYY)'),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty || !RegExp(r'^\d{4}$').hasMatch(value)) {
                          return 'Podaj poprawny rok ważności (YYYY)';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _cvcController,
                      decoration: InputDecoration(labelText: 'Kod CVC (3 cyfry)'),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 3) {
                          return 'Podaj poprawny kod CVC';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_validateCardDetails()) {
                  await _generateInvoice(orderFormResult: orderFormResult, paymentMethod: 'Kartą Płatniczą');
                  _completePayment(orderFormResult: orderFormResult, paymentMethod: 'Karta');
                }
              },
              child: Text('Zatwierdź'),
            ),
          ],
        );
      },
    );
  }

  // Funkcja walidująca dane karty kredytowej
  bool _validateCardDetails() {
    return _cardNumberController.text.isNotEmpty &&
        _cardNumberController.text.length == 16 &&
        _expiryDateController.text.isNotEmpty &&
        RegExp(r'^\d{4}$').hasMatch(_expiryDateController.text) &&
        _cvcController.text.isNotEmpty &&
        _cvcController.text.length == 3;
  }

  // Funkcja obsługująca proces zamówienia
  void _checkout() async {
    // Navigate to the order form page
    final orderFormResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderFormPage(),
      ),
    );

    // Check if the user submitted the order form
    if (orderFormResult != null && orderFormResult.customer != null) {
      setState(() {
        _isLoading = true;
      });

      final config = await paymentConfiguration();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Wybierz formę płatności:'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Komponent płatności Google Pay
                GooglePayButton(
                  paymentConfiguration: config,
                  paymentItems: paymentItems,
                  type: GooglePayButtonType.pay,
                  margin: const EdgeInsets.only(top: 15.0),
                  onPaymentResult: (dynamic paymentResult) {
                    debugPrint('Payment Result: $paymentResult');
                    debugPrint('Complete Payment Result: ${paymentResult.toString()}');

                    if (paymentResult != null && paymentResult['error'] == null) {
                      _completePayment(orderFormResult: orderFormResult, paymentMethod: 'Google Pay');
                    } else if (paymentResult != null && paymentResult['status'] == 'CANCELED') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment canceled by user')),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    } else {
                      debugPrint('Google Pay Error: ${paymentResult['status']}');

                      if (paymentResult != null && paymentResult['error'] != null) {
                        final dynamic errorInfo = paymentResult['error'];
                        debugPrint('Error Code: ${errorInfo['code']}');
                        debugPrint('Error Message: ${errorInfo['message']}');
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment failed. Please try again.')),
                      );

                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  loadingIndicator: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                SizedBox(height: 15.0),
                // Przycisk płatności przy odbiorze
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _generateInvoice(orderFormResult: orderFormResult, paymentMethod: 'Przy odbiorze');
                    _completePayment(orderFormResult: orderFormResult, paymentMethod: 'Gotówka');
                  },
                  child: Text('Przy odbiorze'),
                ),
                // Przycisk płatności kartą kredytową
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _showCardDetailsDialog(orderFormResult);
                  },
                  child: Text('Kartą Płatniczą'),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Anuluj'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      );
    }
  }

// Funkcja generująca paragon
  void printReceipt() {
    print('Receipt:');
    for (var cartItem in widget.cartItems) {
      print('${cartItem.productName} x ${cartItem.quantity} - ${cartItem.price} zł');
    }
    print('Total: ${calculateTotalPrice()} zł');
  }

  // Funkcja finalizująca płatność
  void _completePayment({required OrderFormResult orderFormResult, required String paymentMethod}) async {
    try {
      final pdfFile = await _generateInvoice(orderFormResult: orderFormResult, paymentMethod: paymentMethod);

      final status = await Permission.location.request();
      if (status.isGranted) {
        if (pdfFile != null) {
          PdfApi.openFile(pdfFile);
        } else {
          print('Błąd: Plik PDF nie został pomyślnie wygenerowany.');
        }

        final String invoiceNumber = _generateInvoiceNumber();

        final String displayedPaymentMethod = _getDisplayPaymentMethod(paymentMethod);
        final String displayedPaymentType = _getDisplayPaymentType(paymentMethod);

        final String paymentStatus = displayedPaymentType == 'Przy odbiorze' ? 'Wystawiona' : 'Opłacona';

        final Invoice invoice = Invoice(
          supplier: Supplier(
            name: 'Zami',
            address: 'Aleksandra Ostrowskiego 22',
            paymentInfo: 'Informacje o płatności',
            city: 'Wrocław',
            postalCode: '53-238',
            nip: '1234567890',
          ),
          customer: orderFormResult.customer,
          info: InvoiceInfo(
            date: DateTime.now(),
            dueDate: DateTime.now().add(Duration(days: 7)),
            description: 'Opis faktury',
            number: invoiceNumber,
          ),
          items: _convertCartItemsToInvoiceItems(),
          location: 'Wrocław',
          netTotalAmount: calculateNetTotal(),
          vatTotalAmount: calculateVatTotal(),
          grossTotalAmount: calculateGrossTotal(),
          paymentStatus: paymentStatus,
          paymentDueDate: DateTime.now().add(Duration(days: 7)),
          paymentMethod: displayedPaymentMethod,
          paymentType: displayedPaymentType,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyInvoicesPage(newInvoice: invoice),
          ),
        );

        setState(() {
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aby otworzyć fakturę, udziel uprawnień lokalizacyjnych.')),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Obsługa błędu płatności
      print('Błąd podczas przetwarzania płatności: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Funkcja zwracająca sformatowany sposób płatności
  String _getDisplayPaymentMethod(String paymentMethod) {
    return paymentMethod == 'Google Pay' ? 'Karta' : paymentMethod;
  }

  // Funkcja zwracająca sformatowany sposób płatności
  String _getDisplayPaymentType(String paymentMethod) {
    switch (paymentMethod) {
      case 'Google Pay':
        return 'Google Pay';
      case 'Gotówka':
        return 'Przy odbiorze';
      case 'Karta':
        return 'Kartą Płatniczą';
      default:
        return paymentMethod;
    }
  }

  // Funkcja generująca numer faktury
  String _generateInvoiceNumber() {
    final Random random = Random();
    final int invoiceNumber = random.nextInt(900000) + 100000;
    return invoiceNumber.toString();
  }

  // Funkcja obliczająca łączną cenę
  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var cartItem in widget.cartItems) {
      totalPrice += (cartItem.price * cartItem.quantity);
    }
    return totalPrice;
  }

  // Funkcja generująca fakturę PDF
  Future<File?> _generateInvoice({required OrderFormResult orderFormResult, required String paymentMethod}) async {
    try {
      final supplier = Supplier(
        name: 'Zami',
        address: 'Aleksandra Ostrowskiego 22',
        paymentInfo: 'Informacje o płatności',
        city: 'Wrocław',
        postalCode: '53-238',
        nip: '1234567890',
      );

      final customer = orderFormResult.customer;

      final String invoiceNumber = DateTime.now().millisecondsSinceEpoch.toString();

      final invoiceInfo = InvoiceInfo(
        date: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 7)),
        description: 'Opis faktury',
        number: invoiceNumber,
      );

      final String nipValue = customer.nip.isEmpty ? '—' : customer.nip;

      final Invoice invoice = Invoice(
        supplier: supplier,
        customer: Customer(
          name: customer.name,
          address: customer.address,
          city: customer.city,
          postalCode: customer.postalCode,
          nip: nipValue,
        ),
        info: invoiceInfo,
        items: _convertCartItemsToInvoiceItems(),
        location: 'Wrocław',
        netTotalAmount: calculateNetTotal(),
        vatTotalAmount: calculateVatTotal(),
        grossTotalAmount: calculateGrossTotal(),
        paymentStatus: paymentMethod == 'Przy odbiorze' ? 'Wystawiona' : 'Opłacona',
        paymentDueDate: DateTime.now().add(Duration(days: 7)),
        paymentMethod: paymentMethod,
        paymentType: _getDisplayPaymentType(paymentMethod),
      );

      final pdfFile = await PdfApi.generate(invoice);

      if (pdfFile != null) {
        return pdfFile;
      } else {
        print('Błąd: Generowanie pliku PDF zwróciło null.');
        return null;
      }
    } catch (e) {
      print('Błąd generowania pliku PDF: $e');
      return null;
    }
  }

  // Funkcja obliczająca łączną cenę netto
  double calculateNetTotal() {
    final netTotal = widget.cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    return double.parse(netTotal.toStringAsFixed(2));
  }

  // Funkcja obliczająca łączną wartość podatku VAT
  double calculateVatTotal() {
    final vatTotal = widget.cartItems.fold(0.0, (sum, item) => sum + ((item.price * item.quantity) * 0.23));
    return double.parse(vatTotal.toStringAsFixed(2));
  }

  // Funkcja obliczająca łączną cenę brutto
  double calculateGrossTotal() {
    final grossTotal = widget.cartItems.fold(0.0, (sum, item) => sum + ((item.price * item.quantity) * 1.23));
    return double.parse(grossTotal.toStringAsFixed(2));
  }

  // Funkcja konwertująca elementy koszyka na elementy faktury
  List<InvoiceItem> _convertCartItemsToInvoiceItems() {
    return widget.cartItems
        .map((cartItem) => InvoiceItem(
      description: cartItem.productName,
      date: DateTime.now(),
      quantity: cartItem.quantity,
      vat: 0.23,
      unitPrice: cartItem.price,
      netAmount: double.parse((cartItem.price * cartItem.quantity).toStringAsFixed(2)),
      vatAmount: double.parse(((cartItem.price * cartItem.quantity) * 0.23).toStringAsFixed(2)),
      grossAmount: double.parse(((cartItem.price * cartItem.quantity) * 1.23).toStringAsFixed(2)),
    ))
        .toList();
  }

  // Implementacja metody build dla strony koszyka
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Koszyk'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produkty w koszyku:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cartItem = widget.cartItems[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: Image.asset(
                              'assets/images/${cartItem.productName}.jpg'),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cartItem.productName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Cena: ${(cartItem.price * cartItem.quantity).toStringAsFixed(2)} zł',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('Ilość: ${cartItem.quantity}'),
                        trailing: IconButton(
                          onPressed: () {
                            _removeItem(index);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Suma:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          '${calculateTotalPrice().toStringAsFixed(2)} zł',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              widget.cartItems.clear();
                            });
                          },
                          icon: Icon(Icons.delete),
                          label: Text('Usuń wszystkie'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _checkout,
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text('Zamówić'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}