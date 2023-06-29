import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zami/models/product_model.dart';

class ProductRepository {
  Future<List<Product>> getProductsByCategory(String category) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(category)
        .collection('items')
        .get();

    return querySnapshot.docs.map((doc) => Product.fromDocumentSnapshot(doc)).toList();
  }

  Future<List<Product>> getAllProducts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();

    final products = <Product>[];

    for (final doc in querySnapshot.docs) {
      final category = doc.id;
      final itemsSnapshot = await doc.reference.collection('items').get();
      final items = itemsSnapshot.docs.map((doc) => Product.fromDocumentSnapshot(doc)).toList();
      products.addAll(items.map((item) => item.copyWith(category: category)));
    }

    return products;
  }
}
