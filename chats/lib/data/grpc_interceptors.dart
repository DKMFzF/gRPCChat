// Интерцептор для работы с базой данных и tokens

import 'dart:async';

import 'package:chats/data/db.dart';
import 'package:chats/env.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class GrpcEnterceptors {
  static FutureOr<GrpcError?> tokenEnterceptors (
    ServiceCall call,
    ServiceMethod serviceMethod,
  ) {
    _checkDataBase();

    try {
      final token = call.clientMetadata?['token'] ?? '';
      final jwtClaim = verifyJwtHS256Signature(token, Env.sk);
      jwtClaim.validate();
      return null;
    } catch(_) {
      return GrpcError.unauthenticated('Invalid token');
    }
  }

  /* 
    Проверяет соединение с базой данных 
    и повторно инициализирует базу данных, 
    если соединение закрыто.
  */
  static void _checkDataBase() {
    if (db.connection().isClosed) db = initDataBase();
  }
}