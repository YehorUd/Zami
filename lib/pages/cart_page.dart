import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<PaymentItem> get paymentItems {
    const _paymentItems = [
    PaymentItem(
      amount: '10.00',
      label: 'Product 1',
      status: PaymentItemStatus.final_price,
    ),
    ];
    return _paymentItems;
  }
  void onGooglePayResult(dynamic paymentResult) {
    debugPrint(paymentResult.toString());
  }



  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
      Navigator.pop(context, widget.cartItems); // Pass updated list back
    });
  }

  void _checkout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wybierz metodę płatności:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RawGooglePayButton(
                onPressed: () {},
                type: GooglePayButtonType.plain,
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
          ],
        );
      },
    );
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var cartItem in widget.cartItems) {
      totalPrice += (cartItem.price * cartItem.quantity);
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Koszyk'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                      child: Image.asset('assets/images/${cartItem.productName}.jpg'),
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
                        primary: Colors.red, // Użyty primary zamiast backgroundColor
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _checkout,
                      child: Text('Zamówić'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // Użyty primary zamiast backgroundColor
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // GooglePayButton
            GooglePayButton(
              paymentConfigurationAsset: 'assets/json/google_pay_config.json',
              paymentItems: paymentItems,
              type: GooglePayButtonType.pay,
              margin: const EdgeInsets.only(top: 15.0),
              onPaymentResult: onGooglePayResult,
              loadingIndicator: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          ],
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
