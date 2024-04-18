// Интерцептор для работы с базой данных и tokens

import 'dart:async';

import 'package:auth/data/db.dart';
import 'package:auth/env.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

// Список методов, которые не требуют токена
final _excludeMethods = ['SiginIn', 'SiginUp', 'RefreshToken'];

abstract class GrpcEnterceptors {
  static FutureOr<GrpcError?> tokenEnterceptors (
    ServiceCall call,
    ServiceMethod serviceMethod,
  ) {
    _checkDataBase();

    try {
      // Проверка на методы не требующие токена
      if (_excludeMethods.contains(serviceMethod.name)) return null;

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