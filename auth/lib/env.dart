// Этот код позволяет получить значения переменных окружения
// для настройки параметров такисх как секретный ключ (sk)
// использование переменных окружения позволяет настраивать
// поведение приложения без необходимости изменения кода при компиляции

import 'dart:io';

abstract class Env {
  // Секретный ключ для доступак токену
  static String sk = Platform.environment['SK'] ?? 'SK';

  // Ключ шифрования и дешифрования полей базы данных
  static String dbSk = Platform.environment['DB_SK'] ?? 'E(G+KbPeShVmYq3t';

  // Сроки жизни токенов (в часах)
  static int accessTokenLife = int.tryParse(Platform.environment['ACCESS_TOKEN_LIFE'] ?? '5') ?? 5;
  static int refreshTokenLife = int.tryParse(Platform.environment['REFRESH_TOKEN_LIFE'] ?? '10') ?? 10;
}