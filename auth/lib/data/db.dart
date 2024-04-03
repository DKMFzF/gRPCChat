// Файл для работы с базой данных

import 'package:stormberry/stormberry.dart';

late Database db;

/* 
  Инициализирует и возвращает новый объект базы данных 
  с указанным портом, паролем, 
  именем пользователя и без использования SSL.
*/
Database initDataBase() => Database(
    port: 4500,
    password: 'AngryBirds123',
    username: 'kirill',
    useSSL: false,);