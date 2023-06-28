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
}
