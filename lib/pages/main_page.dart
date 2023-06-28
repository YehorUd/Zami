import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zami/pages/categories_page.dart';
import 'package:zami/pages/products_page.dart';
import 'package:zami/pages/cart_page.dart';
import 'package:zami/pages/login_page.dart';
import 'package:zami/repository/product_repository.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late ProductRepository productRepository; // Dodaj deklarację pola productRepository

  @override
  void initState() {
    productRepository = ProductRepository();
    super.initState();
  }

  late List<Widget> _screens = [
    ProductsPage(productRepository: productRepository, category: 'hamburgers'),
    CategoriesPage(productRepository: productRepository),
    CartPage(cartItems: []),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Przekieruj na ekran logowania
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Zami'),
        actions: [
          if (user != null)
            IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL ?? ''),
              ),
              onPressed: _logout, // Wylogowanie użytkownika
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        showSelectedLabels: false, // Ukryj etykiety dla wybranych ikon
        showUnselectedLabels: false, // Ukryj etykiety dla nie wybranych ikon
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Produkty',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategorie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Koszyk',
          ),
        ],
      ),
    );
  }
}
