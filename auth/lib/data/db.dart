// Файл для работы с базой данных

import 'package:stormberry/stormberry.dart';

late Database db;

/* 
  Инициализирует и возвращает новый объект базы данных 
  с указанным портом, паролем, 
  именем пользователя и без использования SSL.
*/
Database initDataBase() => Database();