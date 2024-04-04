// Функции тестировки и запуска сервера

import 'dart:async';
import 'dart:developer';

import 'package:auth/data/db.dart';
import 'package:auth/domain/auth_rpc.dart';
import 'package:grpc/grpc.dart';

/* 
  Запускает сервер и прослушивает порт 4400. 
  Он инициализирует сервер аутентификации и обрабатывает любые ошибки, 
  возникающие во время выполнения.
*/
Future<void> startServer() async {
  runZonedGuarded(() async {
    // Запуск сервера
    final authServer = Server(
        [AuthRpc()], 
        <Interceptor>[], 
        CodecRegistry(codecs: [GzipCodec()]));
    await authServer.serve(port: 4400);
    log("SERVER LISTING ON PORT ${authServer.port}");

    // Подключение DataBase
    db = initDataBase();
    db.open();
    log('DATABASE OPEN SERVER');

  }, (error, stack) { // Отлов ошибокы
    log("Error", error: error);
  });
}