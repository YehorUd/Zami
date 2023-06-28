import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zami/models/product_model.dart';

class ProductRepository {
  final String collectionId = 'NemyxnTW5okeZfIKEEGr';

  Future<List<Product>> getProducts() async {
    final drinksIds = ['BDGNI6H3r3DydgaVkcXi', 'IDJ9jTJUajMrX3njAnuv', 'D5Aw3sW5pk9yUn6bwF1Q'];
    final pizzasIds = ['YxHIamPu6BwWV0E74e4v', 'rm3LSgqsG7VFh48PuzSF', 'tcJoeU54svnZNJTPn6WH'];
    final hamburgersIds = ['cta3bb1bOv1nQjthnj4N', 'nT4u1ItMY6Kou8orEgHa', 'RRUSpMQiLMCp18TfebxN'];

    final drinksList = await _getItemsFromCollection('drinks', drinksIds);
    final pizzasList = await _getItemsFromCollection('pizzas', pizzasIds);
    final hamburgersList = await _getItemsFromSubcollection('hamburgers', hamburgersIds);

    final productsList = [
      ...drinksList,
      ...pizzasList,
      ...hamburgersList,
    ];

    return productsList;
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(collectionId)
        .collection('categories')
        .doc('SufGNY8fdEdpEv405Aun')
        .collection(category.toLowerCase())
        .get();
    final productList = categorySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Product(
        name: data['name'] ?? '',
        price: (data['price'] ?? 0).toDouble(),
        category: category,
        imageName: null,
      );
    }).toList();

    return productList;
  }

  Future<List<Product>> _getItemsFromCollection(String collection, List<String> itemIds) async {
    final collectionRef = FirebaseFirestore.instance.collection(collection);
    final snapshots = await Future.wait(
      itemIds.map((itemId) => collectionRef.doc(itemId).get()),
    );
    final itemList = snapshots.map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      return Product(
        name: data['name'] ?? '',
        price: (data['price'] ?? 0).toDouble(),
        category: collection.capitalize(),
        imageName: null,
      );
    }).toList();

    return itemList;
  }

  Future<List<Product>> _getItemsFromSubcollection(String collection, List<String> itemIds) async {
    final subcollectionRef = FirebaseFirestore.instance
        .collection('products')
        .doc(collectionId)
        .collection('categories')
        .doc('SufGNY8fdEdpEv405Aun')
        .collection('hamburgers');

    final snapshots = await Future.wait(
      itemIds.map((itemId) => subcollectionRef.doc(itemId).get()),
    );

    final itemList = snapshots.map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      return Product(
          name: data['name'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
        category: collection.capitalize(),
        imageName: null,
      );
    }).toList();
    return itemList;
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}