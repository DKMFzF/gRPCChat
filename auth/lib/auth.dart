import 'dart:async';
import 'dart:developer';

import 'package:auth/domain/auth_rpc.dart';
import 'package:grpc/grpc.dart';

/* 
  Запускает сервер и прослушивает порт 4400. 
  Он инициализирует сервер аутентификации и обрабатывает любые ошибки, 
  возникающие во время выполнения.
*/
Future<void> startServer() async {
  final authServer = Server(
    [AuthRpc()],
    <Interceptor>[],
    CodecRegistry(codecs: [GzipCodec()]),);
  await authServer.serve(port: 4400);
  log("Server listening on port ${authServer.port}");
  runZonedGuarded(() => null, (error, stackTrace) {
    log("Error", error: error);
  });
}