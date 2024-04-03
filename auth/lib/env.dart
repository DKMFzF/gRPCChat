// Этот код позволяет получить значения переменных окружения
// для настройки параметров таких как секретный ключ (sk)
// использование переменных окружения позволяет настраивать
// поведение приложения без необходимости изменения кода при компиляции

import 'dart:io';

abstract class Env {
  static String sk = Platform.environment['SK'] ?? 'SK';
  static int accessTokenLife = int.tryParse(Platform.environment['ACCESS_TOKEN_LIFE'] ?? '5') ?? 5;
  static int refreshTokenLife = int.tryParse(Platform.environment['REFRESH_TOKEN_LIFE'] ?? '10') ?? 10;
}