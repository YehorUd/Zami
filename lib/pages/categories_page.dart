import 'package:flutter/material.dart';
import 'products_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('products')
                .doc('categories')
                .collection('drinks')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final categories = snapshot.data!.docs;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categories.map((category) {
                    final categoryName = category['name'];
                    final categoryImage = category['image'];

                    return ElevatedButton(
                      onPressed: () {
                        navigateToProductsPage(context, categoryName);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            child: Image.network(
                              categoryImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(categoryName),
                        ],
                      ),
                    );
                  }).toList(),
                );
              } else if (snapshot.hasError) {
                return Text('Wystąpił błąd: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
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
