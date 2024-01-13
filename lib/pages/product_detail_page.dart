import 'package:flutter/material.dart';
import 'package:zami/models/product_model.dart';
import 'package:zami/pages/cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final List<CartItem> cartItems;
  final Function(List<CartItem>) onCartUpdated;

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.cartItems,
    required this.onCartUpdated,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedQuantity = 1;

  void _showQuantityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Wybierz ilość'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (selectedQuantity > 1) {
                              selectedQuantity--;
                            }
                          });
                        },
                        icon: Icon(Icons.remove),
                        color: Colors.red,
                      ),
                      Text(
                        '$selectedQuantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedQuantity++;
                          });
                        },
                        icon: Icon(Icons.add),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _addToCart();
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text('Dodaj do koszyka'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addToCart() {
    final existingCartItem = widget.cartItems.firstWhere(
          (item) => item.productName == widget.product.name,
      orElse: () => CartItem(productName: widget.product.name, price: 0, quantity: 0),
    );

    if (existingCartItem.quantity > 0) {
      widget.cartItems.remove(existingCartItem);
    }

    widget.cartItems.add(CartItem(
      productName: widget.product.name,
      price: widget.product.price ?? 0,
      quantity: selectedQuantity,
    ));

    widget.onCartUpdated(widget.cartItems);

    Navigator.of(context).pop(widget.cartItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/${widget.product.imageName}.jpg',
                  height: 400.0, // Ustaw wysokość obrazu na odpowiednią wartość
                  width: 500.0, // Ustaw szerokość obrazu na odpowiednią wartość
                  fit: BoxFit.cover, // Dopasuj obraz do okna
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Cena: ${widget.product.price} zł',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Opis: ${widget.product.description}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _showQuantityDialog,
                  child: Text('Dodaj do koszyka'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
