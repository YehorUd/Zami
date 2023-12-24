import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageName;
  final String description; // Add this line

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageName,
    required this.description, // Add this line
  });

  factory Product.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      imageName: data['imageName'] ?? '',
      description: data['description'] ?? '', // Add this line
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? imageName,
    String? description, // Add this line
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      imageName: imageName ?? this.imageName,
      description: description ?? this.description, // Add this line
    );
  }
}
