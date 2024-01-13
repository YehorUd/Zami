import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zami/pages/categories_page.dart';
import 'package:zami/pages/products_page.dart';
import 'package:zami/pages/my_invoices_page.dart';
import 'package:zami/pages/login_page.dart';
import 'package:zami/repository/product_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zami/theme.dart';

// Główna klasa aplikacji Flutter
void main() async {
  // Zapewnienie zainicjalizowania wszystkich bindingów Fluttera
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Firebase przed uruchomieniem aplikacji
  await Firebase.initializeApp();

  // Uruchomienie głównej aplikacji
  runApp(MainApp());
}

// Klasa reprezentująca główną aplikację Flutter
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Konfiguracja tytułu i motywu aplikacji
    return MaterialApp(
      title: 'Zami',
      theme: appTheme,
      home: MainPage(),
    );
  }
}

// Klasa reprezentująca główną stronę aplikacji
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

// Stan klasy MainPage, zarządzający aktualnie wybranym ekranem i repozytorium produktów
class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late ProductRepository productRepository;

  @override
  void initState() {
    // Inicjalizacja repozytorium produktów przy tworzeniu stanu
    productRepository = ProductRepository();
    super.initState();
  }

  // Lista ekranów do wyświetlenia w dolnym pasku nawigacyjnym
  late List<Widget> _screens = [
    CategoriesPage(productRepository: productRepository),
    ProductsPage(productRepository: productRepository, category: null),
    MyInvoicesPage(newInvoice: null),
  ];

  // Obsługa zmiany wybranego ekranu w dolnym pasku nawigacyjnym
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Wylogowanie użytkownika i nawigacja do strony logowania
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pobranie aktualnie zalogowanego użytkownika
    User? user = FirebaseAuth.instance.currentUser;

    // Budowa struktury widoku aplikacji
    return Scaffold(
      appBar: AppBar(
        title: Text('Zami'),
        // Dodanie przycisku wylogowania w pasku aplikacji
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
        ),
        // Dodanie obrazka użytkownika w pasku aplikacji, jeśli użytkownik jest zalogowany
        actions: [
          if (user != null)
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ''),
            ),
        ],
      ),
      // Wyświetlenie aktualnie wybranego ekranu
      body: _screens[_currentIndex],
      // Dolny pasek nawigacyjny
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        // Elementy nawigacyjne
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategorie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Produkty',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Faktury',
          ),
        ],
      ),
    );
  }
}
