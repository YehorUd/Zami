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

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final productList = widget.category != null
        ? await widget.productRepository.getProductsByCategory(widget.category!)
        : await widget.productRepository.getAllProducts();
    setState(() {
      products = productList;
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nazwa',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Cena',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.name),
                      Text('${product.price.toStringAsFixed(2)} zł'),
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
