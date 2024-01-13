import 'package:flutter/material.dart';
import 'package:zami/repository/product_repository.dart';
import 'package:zami/pages/products_page.dart';
import 'package:zami/pages/categories_page.dart';

// Klasa kontrolera dla zarządzania produktami
class ProductController {
  // Repozytorium produktów
  final ProductRepository productRepository;

  // Konstruktor, który wymaga przekazania repozytorium produktów
  ProductController({required this.productRepository});

  // Metoda do nawigowania do strony produktów
  void navigateToProductsPage(BuildContext context, String? category) {
    // Wykorzystanie nawigatora do przechodzenia do strony produktów
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

  // Metoda do budowania strony kategorii
  Widget buildCategoriesPage(BuildContext context) {
    // Utworzenie i zwrócenie strony kategorii
    return CategoriesPage(
      productRepository: productRepository,
    );
  }
}
