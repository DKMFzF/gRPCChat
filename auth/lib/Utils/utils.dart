// Класс для утилит

import 'dart:convert';

import 'package:auth/data/user/user.dart';
import 'package:auth/env.dart';
import 'package:auth/generated/auth.pb.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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

  /*  
    Изъятие id из токена
    @param: String token - токен для извлечения id
    return: значение: id пользователя из токена
    Exception: GrpcError в случае отсутствия id в токене
  */
  static int getIdFromToken(String token) {

    // Изъятие id из токена
    final jwtClaim = verifyJwtHS256Signature(token, Env.sk);
    final id = int.tryParse(jwtClaim['user_id']);

    // Проверерка на получение id из токена
    if (id == null) throw GrpcError.dataLoss('User Id not found');
    return id;
  }

  /* 
    Извлекает идентификатор из метаданных клиента 
    в данном объекте ServiceCall, используя токен доступа. 
    Возвращает идентификатор, полученный из токена.
  */
  static int getIdFromMetaData(ServiceCall serviceCall) {
    final accessToken = serviceCall.clientMetadata?['access_token'] ?? ''; 
    return getIdFromToken(accessToken);
  }

  // Конвертация пользователя в UserDto (Через паттерн строитель)
  static UserDto convertUserDto(UserView user) => UserDto()
    ..id = user.id.toString()
    ..email = encryptField(user.email, isDecode: true)
    ..username = user.username;

  // Проверка на валидность email
  static bool isValidEmail(String email) {
    if (email.split("@").length == 2) return true;
    return false;
  }

  // Проверка на валидность пароля
  static bool isValidPassword(String password) {
    if (4 <= password.length && password.length <= 20) return true;
    return false;
  }

  // Парсинг Users в List<UserDto>
  static ListUsersDto convertListUsersDto(List<UserView> users) {
    try {
      return ListUsersDto(
        users: [...users.map((e) => convertUserDto(e))],
      );
    } catch (e) {
      throw GrpcError.internal('ERROR METHOD convertListUsersDto: ${e.toString()}');
    }
  } 
}