import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zami/models/product_model.dart';

class ProductRepository {
  Future<List<Product>> getProductsByCategory(String category) async {
    final productsRef = FirebaseFirestore.instance.collection('products');
    final categoryRef = productsRef.doc('categories').collection(category);
    final querySnapshot = await categoryRef.get();

    return querySnapshot.docs.map((doc) => Product.fromDocumentSnapshot(doc)).toList();
  }

  Future<List<Product>> getAllProducts() async {
    final productsRef = FirebaseFirestore.instance.collection('products');
    final querySnapshot = await productsRef.get();

    return querySnapshot.docs.map((doc) => Product.fromDocumentSnapshot(doc)).toList();
  }
}
