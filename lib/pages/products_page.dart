import 'package:flutter/material.dart';
import 'package:zami/models/product_model.dart';
import 'package:zami/repository/product_repository.dart';

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
  List<String> cartItems = [];
  Set<int> favoriteIndices = Set<int>();

  @override
  void initState() {
    super.initState();
    fetchProducts();
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

  void addToCart(String productName) {
    setState(() {
      cartItems.add(productName);
    });
  }

  void toggleFavorite(int index) {
    setState(() {
      if (favoriteIndices.contains(index)) {
        favoriteIndices.remove(index);
      } else {
        favoriteIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nazwa',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Cena',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isFavorite = favoriteIndices.contains(index);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(product.name),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(2)} zł',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8.0),
                            IconButton(
                              onPressed: () {
                                toggleFavorite(index);
                              },
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
