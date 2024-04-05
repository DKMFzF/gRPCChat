// Создание бд

import 'package:stormberry/stormberry.dart';

late Database db;

/* 
  Инициализирует и возвращает новый объект базы данных 
  с указанным портом, паролем, 
  именем пользователя и без использования SSL.
*/
Database initDataBase() => Database(
  debugPrint: true,
  host: '127.0.0.1',
  port: 4501,
  user: 'kirill',
  password: 'AngryBirds123',
  useSSL: false
); // Времянка на конструктор