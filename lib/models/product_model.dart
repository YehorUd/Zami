import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final double price;
  final String category;
  final String? imageName;

  Product({
    required this.name,
    required this.price,
    required this.category,
    this.imageName,
  });

  factory Product.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Product(
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: '',
      imageName: data['imageName'],
    );
  }
}
