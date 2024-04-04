// Класс для утилит

import 'dart:convert';

import 'package:auth/env.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

abstract class Utils {
  // Конвертация парля в кэш
  static String getCashPassword(String password) {
    final bytes = utf8.encode(password + Env.sk); // Конвертация пароля в байтовую послужовательность
    return sha256.convert(bytes).toString(); // Создания кэша из байтовой последовательности
  }

  // шифровка и дешифровка данных по алгоритму шифрования AES
  static String encryptField(String value, {bool isDecode = false}) {
    final key = Key.fromUtf8(Env.dbSk); // Ключ переводится в битовую послужовательность
    final iv = IV.fromLength(16); // Создание вектора для дополнительной защиты (увеличения дифузии)
    final encryptor = Encrypter(AES(key, mode: AESMode.ecb)); // Создание криптоключа

    return isDecode
      ? encryptor.decrypt64(value, iv: iv) // Дешифровка
      : encryptor.encrypt(value, iv: iv).base64; // Шифровка
  }
}