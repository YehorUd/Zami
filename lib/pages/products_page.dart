import 'package:flutter/material.dart';
import 'package:zami/models/product_model.dart';
import 'package:zami/repository/product_repository.dart';
import 'package:zami/pages/cart_page.dart';

class ProductsPage extends StatefulWidget {
  final ProductRepository productRepository;
  final String? category;

  const ProductsPage({
    Key? key,
    required this.productRepository,
    this.category,
  }) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    cartItems = [];
  }

  Future<void> fetchProducts() async {
    print('Category: ${widget.category}');
    final productList = widget.category != null
        ? await widget.productRepository.getProductsByCategory(widget.category!)
        : await widget.productRepository.getAllProducts();
    setState(() {
      products = productList;
    });
  }

  void addToCart(String productName, double? price, int quantity) {
    setState(() {
      final existingCartItem = cartItems.firstWhere(
            (item) => item.productName == productName,
        orElse: () => CartItem(productName: productName, price: 0, quantity: 0),
      );

      if (existingCartItem.quantity > 0) {
        cartItems.remove(existingCartItem);
      }

      cartItems.add(CartItem(productName: productName, price: price ?? 0, quantity: quantity));
    });
  }

  void _showQuantityDialog(String productName, double price) {
    int quantity = 1;

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
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                        icon: Icon(Icons.remove),
                        color: Colors.red,
                      ),
                      Text(
                        '$quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
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
                    addToCart(productName, price, quantity);
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
  void _openCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartItems: cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products Page'),
        actions: [
          IconButton(
            onPressed: _openCartPage,
            icon: Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Nazwa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Cena',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                final imageName = product.imageName;

                return ListTile(
                  leading: SizedBox(
                    width: 60.0,
                    height: 60.0,
                    child: Image.asset('assets/images/$imageName.jpg'),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.name),
                      Text(
                        '${product.price} zł',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      _showQuantityDialog(product.name, product.price);
                    },
                    icon: Icon(Icons.add_shopping_cart),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
