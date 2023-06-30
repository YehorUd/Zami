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
        automaticallyImplyLeading: false, // Usuń przycisk powrotu
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryButton(
                    context,
                    'pizzas',
                    'assets/images/pizza.png',
                    'Pizzas',
                  ),
                  SizedBox(width: 24),
                  _buildCategoryButton(
                    context,
                    'hamburgers',
                    'assets/images/hamburger.png',
                    'Hamburgers',
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryButton(
                    context,
                    'drinks',
                    'assets/images/drinks.png',
                    'Napoje',
                  ),
                  SizedBox(width: 24),
                  _buildCategoryButton(
                    context,
                    null,
                    'assets/images/products.png',
                    'Wszystkie\nprodukty',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
      BuildContext context,
      String? category,
      String imagePath,
      String label,
      ) {
    return SizedBox(
      width: 140,
      height: 140,
      child: ElevatedButton(
        onPressed: () {
          navigateToProductsPage(context, category);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void navigateToProductsPage(BuildContext context, String? category) {
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
