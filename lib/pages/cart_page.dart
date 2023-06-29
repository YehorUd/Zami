import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final List<String> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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
                  final productName = widget.cartItems[index];
                  return ListTile(
                    title: Text(productName),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


