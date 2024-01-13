import 'package:flutter/material.dart';
import 'products_page.dart';
import 'package:zami/repository/product_repository.dart';

// Strona wyświetlająca kategorie produktów
class CategoriesPage extends StatelessWidget {
  final ProductRepository productRepository;

  // Konstruktor przyjmujący repozytorium produktów
  const CategoriesPage({Key? key, required this.productRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategorie'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pierwszy rząd kategorii
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kategoria: Pizzas
                  _buildCategoryButton(
                    context,
                    'pizzas',
                    'assets/images/pizza.png',
                    'Pizzas',
                  ),
                  SizedBox(width: 24),
                  // Kategoria: Hamburgers
                  _buildCategoryButton(
                    context,
                    'hamburgers',
                    'assets/images/hamburger.png',
                    'Hamburgers',
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Drugi rząd kategorii
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kategoria: Drinks
                  _buildCategoryButton(
                    context,
                    'drinks',
                    'assets/images/drinks.png',
                    'Napoje',
                  ),
                  SizedBox(width: 24),
                  // Kategoria: Dodatki
                  _buildCategoryButton(
                    context,
                    'dodatki',
                    'assets/images/dodatki.png',
                    'Dodatki',
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Trzeci rząd kategorii
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kategoria: Wszystkie produkty
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

  // Funkcja budująca przycisk kategorii
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
          // Przejście do strony produktów po naciśnięciu przycisku
          navigateToProductsPage(context, category);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Obrazek kategorii
            Container(
              width: 80,
              height: 80,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            // Etykieta kategorii
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

  // Funkcja nawigująca do strony produktów
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
