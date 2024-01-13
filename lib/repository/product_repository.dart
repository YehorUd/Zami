import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zami/models/product_model.dart';

// Klasa odpowiedzialna za interakcję z bazą danych dotyczącą produktów
class ProductRepository {

  // Pobiera produkty z danej kategorii z bazy danych
  Future<List<Product>> getProductsByCategory(String category) async {
    // Pobierz snapshot z kolekcji 'products'
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();

    // Lista przechowująca produkty
    final products = <Product>[];

    // Iteruj po dokumentach w kolekcji 'products'
    for (final doc in querySnapshot.docs) {
      // Pobierz snapshot z podkolekcji 'items'
      final itemsSnapshot = await doc.reference.collection('items').get();

      // Mapuj dokumenty na obiekty Product za pomocą metody fromDocumentSnapshot
      final items = itemsSnapshot.docs.map((doc) => Product.fromDocumentSnapshot(doc)).toList();

      // Filtruj produkty według kategorii
      final filteredItems = items.where((item) => item.category == category).toList();

      // Dodaj filtrowane produkty do ogólnej listy
      products.addAll(filteredItems);
    }

    // Zwróć listę produktów
    return products;
  }

  // Pobiera wszystkie produkty z bazy danych
  Future<List<Product>> getAllProducts() async {
    // Pobierz snapshot z kolekcji 'products'
    final querySnapshot = await FirebaseFirestore.instance.collection('products').get();

    // Lista przechowująca produkty
    final products = <Product>[];

    // Iteruj po dokumentach w kolekcji 'products'
    for (final doc in querySnapshot.docs) {
      // Pobierz nazwę kategorii
      final category = doc.id;

      // Pobierz snapshot z podkolekcji 'items'
      final itemsSnapshot = await doc.reference.collection('items').get();

      // Mapuj dokumenty na obiekty Product za pomocą metody fromDocumentSnapshot
      final items = itemsSnapshot.docs.map((doc) => Product.fromDocumentSnapshot(doc)).toList();

      // Dodaj produkty do ogólnej listy, nadając im kategorię
      products.addAll(items.map((item) => item.copyWith(category: category)));
    }

    // Zwróć listę produktów
    return products;
  }
}
