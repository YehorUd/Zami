import 'package:flutter/material.dart';
import 'package:zami/models/product_model.dart';
import 'package:zami/pages/cart_page.dart';
import 'package:zami/models/cart_item.dart';

// Strona szczegółów produktu w aplikacji Flutter
class ProductDetailPage extends StatefulWidget {
  // Produkt do wyświetlenia szczegółów
  final Product product;

  // Lista elementów koszyka
  final List<CartItem> cartItems;

  // Funkcja do aktualizacji koszyka
  final Function(List<CartItem>) onCartUpdated;

  // Konstruktor
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
  // Wybrana ilość produktu
  int selectedQuantity = 1;

  // Funkcja wyświetlająca dialog z wyborem ilości produktu
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
                  // Interaktywne przyciski do zwiększania i zmniejszania ilości
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
                // Przycisk dodawania do koszyka
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

  // Funkcja dodająca produkt do koszyka
  void _addToCart() {
    // Sprawdzenie, czy produkt już istnieje w koszyku
    final existingCartItem = widget.cartItems.firstWhere(
          (item) => item.productName == widget.product.name,
      orElse: () => CartItem(productName: widget.product.name, price: 0, quantity: 0),
    );

    // Jeśli produkt już istnieje w koszyku, usuń go
    if (existingCartItem.quantity > 0) {
      widget.cartItems.remove(existingCartItem);
    }

    // Dodaj nowy produkt do koszyka
    widget.cartItems.add(CartItem(
      productName: widget.product.name,
      price: widget.product.price ?? 0,
      quantity: selectedQuantity,
    ));

    // Aktualizacja koszyka i zamknięcie dialogu
    widget.onCartUpdated(widget.cartItems);
    Navigator.of(context).pop(widget.cartItems);
  }

  // Budowa widoku strony
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
              // Wyświetlenie obrazka produktu
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/${widget.product.imageName}.jpg',
                  height: 400.0,
                  width: 500.0,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16.0),
              // Wyświetlenie ceny produktu
              Text(
                'Cena: ${widget.product.price} zł',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16.0),
              // Wyświetlenie opisu produktu
              Text(
                'Opis: ${widget.product.description}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              SizedBox(height: 16.0),
              // Przycisk dodawania do koszyka
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
