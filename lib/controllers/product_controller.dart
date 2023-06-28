import 'package:flutter/material.dart';
import 'package:zami/repository/product_repository.dart';
import 'package:zami/pages/products_page.dart';
import 'package:zami/pages/categories_page.dart';

class ProductController {
  final ProductRepository productRepository;

  ProductController({required this.productRepository});

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

  Widget buildCategoriesPage(BuildContext context) {
    return CategoriesPage(
      productRepository: productRepository);
  }
}
