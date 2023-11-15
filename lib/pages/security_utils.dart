import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';

String hashPassword(String password) {
  final salt = BCrypt.gensalt();
  return BCrypt.hashpw(password, salt);
}

bool verifyPassword(String password, String hashedPassword) {
  return BCrypt.checkpw(password, hashedPassword);
}
