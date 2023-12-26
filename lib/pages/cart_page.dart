import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:zami/models/invoice.dart';
import 'package:zami/helper/pdf_api.dart';
import 'dart:io';
import 'package:zami/pages/my_invoices_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zami/pages/order_form_page.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = false;
  OrderFormResult? orderFormResult;
  List<PaymentItem> get paymentItems {
    List<PaymentItem> items = [];

    double totalAmount = calculateTotalPrice();

    items.add(
      PaymentItem(
        amount: totalAmount.toStringAsFixed(2),
        label: 'Suma',
        status: PaymentItemStatus.final_price,
      ),
    );

    return items;
  }

  Future<PaymentConfiguration> paymentConfiguration() async {
    return PaymentConfiguration.fromAsset('json/google_pay_config.json');
  }

  void onGooglePayResult(dynamic paymentResult, OrderFormResult orderFormResult) {
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
  }

  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
      if (widget.cartItems.isEmpty) {
        Navigator.pop(context, widget.cartItems);
      }
    });
  }
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();

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




  bool _validateCardDetails() {
    return _cardNumberController.text.isNotEmpty &&
        _cardNumberController.text.length == 16 &&
        _expiryDateController.text.isNotEmpty &&
        RegExp(r'^\d{4}$').hasMatch(_expiryDateController.text) &&
        _cvcController.text.isNotEmpty &&
        _cvcController.text.length == 3;
  }


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
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _generateInvoice(orderFormResult: orderFormResult, paymentMethod: 'Przy odbiorze');
                    _completePayment(orderFormResult: orderFormResult, paymentMethod: 'Gotówka');
                  },
                  child: Text('Przy odbiorze'),
                ),
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



  void printReceipt() {
    print('Receipt:');
    for (var cartItem in widget.cartItems) {
      print('${cartItem.productName} x ${cartItem.quantity} - ${cartItem.price} zł');
    }
    print('Total: ${calculateTotalPrice()} zł');
  }

  void _completePayment({required OrderFormResult orderFormResult, required String paymentMethod}) async {
    try {
      final pdfFile = await _generateInvoice(orderFormResult: orderFormResult, paymentMethod: paymentMethod);

      // Sprawdź uprawnienia przed otwarciem faktury
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

        // Przekieruj do MyInvoicesPage po udanej płatności
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
        // Użytkownik nie udzielił uprawnień
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aby otworzyć fakturę, udziel uprawnień lokalizacyjnych.')),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Błąd podczas przetwarzania płatności: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }




  String _getDisplayPaymentMethod(String paymentMethod) {
    // Jeśli płatność jest dokonywana za pomocą Google Pay, zwróć "Karta"
    return paymentMethod == 'Google Pay' ? 'Karta' : paymentMethod;
  }

  String _getDisplayPaymentType(String paymentMethod) {
    // Ustawienie odpowiedniego typu płatności na podstawie formy płatności
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

  String _generateInvoiceNumber() {
    // Generuj unikalny numer faktury składający się z 6 cyfr
    final Random random = Random();
    final int invoiceNumber = random.nextInt(900000) + 100000;
    return invoiceNumber.toString();
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var cartItem in widget.cartItems) {
      totalPrice += (cartItem.price * cartItem.quantity);
    }
    return totalPrice;
  }

  // New function to generate the PDF invoice
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

      // Użyj timestampa (czasu) jako unikalnego numeru faktury
      final String invoiceNumber = DateTime.now().millisecondsSinceEpoch.toString();

      final invoiceInfo = InvoiceInfo(
        date: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 7)),
        description: 'Opis faktury',
        number: invoiceNumber,
      );

      // Jeśli NIP jest pusty, ustaw go na "-"
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





  double calculateNetTotal() {
    final netTotal = widget.cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    return double.parse(netTotal.toStringAsFixed(2)); // Zaokrąglanie do dwóch miejsc po przecinku
  }

  double calculateVatTotal() {
    final vatTotal = widget.cartItems.fold(0.0, (sum, item) => sum + ((item.price * item.quantity) * 0.23));
    return double.parse(vatTotal.toStringAsFixed(2)); // Zaokrąglanie do dwóch miejsc po przecinku
  }

  double calculateGrossTotal() {
    final grossTotal = widget.cartItems.fold(0.0, (sum, item) => sum + ((item.price * item.quantity) * 1.23));
    return double.parse(grossTotal.toStringAsFixed(2)); // Zaokrąglanie do dwóch miejsc po przecinku
  }

  List<InvoiceItem> _convertCartItemsToInvoiceItems() {
    return widget.cartItems
        .map((cartItem) => InvoiceItem(
      description: cartItem.productName,
      date: DateTime.now(),
      quantity: cartItem.quantity,
      vat: 0.23, // VAT w przykładowy sposób
      unitPrice: cartItem.price,
      netAmount: double.parse((cartItem.price * cartItem.quantity).toStringAsFixed(2)), // Zaokrąglanie do dwóch miejsc po przecinku
      vatAmount: double.parse(((cartItem.price * cartItem.quantity) * 0.23).toStringAsFixed(2)), // Zaokrąglanie do dwóch miejsc po przecinku
      grossAmount: double.parse(((cartItem.price * cartItem.quantity) * 1.23).toStringAsFixed(2)), // Zaokrąglanie do dwóch miejsc po przecinku
    ))
        .toList();
  }


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

class CartItem {
  final String productName;
  final int quantity;
  final double price;

  CartItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });
}