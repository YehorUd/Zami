import 'package:flutter/material.dart';
import 'products_page.dart';
import 'package:zami/repository/product_repository.dart';

class CategoriesPage extends StatelessWidget {
  final ProductRepository productRepository;

  const CategoriesPage({Key? key, required this.productRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategorie'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  navigateToProductsPage(context, 'pizzas');
                },
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        'assets/images/pizza.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Pizzas'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  navigateToProductsPage(context, 'hamburgers');
                },
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        'assets/images/hamburger.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Hamburgers'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  navigateToProductsPage(context, 'napoje');
                },
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        "assets/images/drinks.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Napoje'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToProductsPage(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsPage(
          productRepository: productRepository,
          category: category,
        ),
      ),
    );
  }
}
