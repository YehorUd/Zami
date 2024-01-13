import 'package:cloud_firestore/cloud_firestore.dart';

// Klasa reprezentująca produkt
class Product {
  final String id;           // Unikalny identyfikator produktu
  final String name;         // Nazwa produktu
  final double price;        // Cena produktu
  final String category;     // Kategoria produktu
  final String imageName;    // Nazwa obrazu produktu
  final String description;  // Opis produktu

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageName,
    required this.description,
  });

  // Konstruktor fabryczny tworzący instancję produktu na podstawie dokumentu Firestore
  factory Product.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      imageName: data['imageName'] ?? '',
      description: data['description'] ?? '',
    );
  }

  // Metoda pozwalająca na kopiowanie produktu i jednocześnie dokonywanie zmian
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? imageName,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      imageName: imageName ?? this.imageName,
      description: description ?? this.description,
    );
  }
}
