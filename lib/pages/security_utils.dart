
// ╔════════════════════════════════════════════════════════╗
// ║                      KOD ZABEZPIECZAJĄCY                 ║
// ╚════════════════════════════════════════════════════════╝

import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';

// Funkcja do hashowania hasła przy użyciu algorytmu bcrypt
String hashPassword(String password) {

  // Generowanie soli (randomowego składnika) dla bezpiecznego hashowania
  final salt = BCrypt.gensalt();

  // Zwracanie zahaszowanego hasła
  return BCrypt.hashpw(password, salt);
}

// Funkcja do weryfikacji hasła
bool verifyPassword(String password, String hashedPassword) {

  // Sprawdzanie, czy hasło zgadza się z zahaszowanym hasłem
  return BCrypt.checkpw(password, hashedPassword);
}
