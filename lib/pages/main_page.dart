import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zami/pages/categories_page.dart';
import 'package:zami/pages/products_page.dart';
import 'package:zami/pages/login_page.dart';
import 'package:zami/repository/product_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zami/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zami',
      theme: appTheme,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late ProductRepository productRepository;

  @override
  void initState() {
    productRepository = ProductRepository();
    super.initState();
  }

  late List<Widget> _screens = [
    CategoriesPage(productRepository: productRepository),
    ProductsPage(productRepository: productRepository, category: null),
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
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Zami'),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
        ),
        actions: [
          if (user != null)
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ''),
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategorie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Produkty',
          ),
        ],
      ),
    );
  }
}

