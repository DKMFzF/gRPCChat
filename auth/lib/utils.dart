// Класс для утилит

import 'dart:convert';

import 'package:auth/env.dart';
import 'package:crypto/crypto.dart';

abstract class Utils {
  // Конвертация парля в кэш
  static String getCashPassword(String password) {
    final bytes = utf8.encode(password + Env.sk);
    return sha256.convert(bytes).toString();
  }
}