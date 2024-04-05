// Этот код позволяет получить значения переменных окружения
// для настройки параметров такисх как секретный ключ (sk)
// использование переменных окружения позволяет настраивать
// поведение приложения без необходимости изменения кода при компиляции

import 'dart:io';

abstract class Env {
  // Порт сервера
  static int prot = int.tryParse(Platform.environment['PORT']!)!;

  // Секретный ключ для доступак токену
  static String sk = Platform.environment['SK']!;

  // Ключ шифрования и дешифрования полей базы данных
  static String dbSk = Platform.environment['DB_SK']!;

  // Сроки жизни токенов (в часах)
  static int accessTokenLife = int.parse(Platform.environment['ACCESS_TOKEN_LIFE']!);
  static int refreshTokenLife = int.parse(Platform.environment['REFRESH_TOKEN_LIFE']!);
}