import 'package:auth/data/db.dart';
import 'package:auth/data/user/user.dart';
import 'package:auth/env.dart';
import 'package:auth/generated/auth.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/src/server/call.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AuthRpc extends AuthRpcServiceBase {

  @override
  Future<ResponseDto> deleteUser(ServiceCall call, RequestDto request) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<UserDto> fetchUser(ServiceCall call, RequestDto request) {
    // TODO: implement fetchUser
    throw UnimplementedError();
  }

  @override
  Future<TokensDto> refreshToken(ServiceCall call, TokensDto request) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  /*
    Функция, которая регистрирует пользователя, 
    используя данный вызов службы и пользовательские данные, 
    возвращая TokensDto.
  */
  @override
  Future<TokensDto> siginIn(ServiceCall call, UserDto request) {
    return Future(() => TokensDto(accessToken: "test", refreshToken: "test"));
  }
  
  /*
    Функция, которая регистрирует пользователя, 
    используя данный вызов службы и пользовательские данные, 
    возвращая TokensDto
  */
  @override
  Future<TokensDto> siginUp(ServiceCall call, UserDto request) async {
    // Проверка данных
    if (db.connection().isClosed) db = initDataBase() ;
    if (request.email.isEmpty) throw GrpcError.invalidArgument('Email not found');
    if (request.password.isEmpty) throw GrpcError.invalidArgument('Password not found');
    if (request.username.isEmpty) throw GrpcError.invalidArgument('Username not fount');

    // Создание id пол ьзователя при обращении к базе данных
    final id = await db.users.insertOne(UserInsertRequest(
      username: request.username, 
      email: request.email,
      password: request.password
    ));

    return _createTokens(id.toString()); // Создание токена
  }

  @override
  Future<UserDto> updateUser(ServiceCall call, UserDto request) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  /* 
    Генерирует TokensDto, содержащий токены доступа 
    и обновления для данного идентификатора пользователя.
  */
  TokensDto _createTokens(String id) {
    // Генерация токенов
    final accessTokenSet = JwtClaim(
      maxAge: Duration(hours: Env.accessTokenLife),
      otherClaims: {'user_id': id},);
    final refreshTokenClaim = JwtClaim(
      maxAge: Duration(hours: Env.refreshTokenLife),
      otherClaims: {'user_id': id},
    );

    return TokensDto(
      accessToken: issueJwtHS256(accessTokenSet, Env.sk),
      refreshToken: issueJwtHS256(refreshTokenClaim, Env.sk), 
    );
  }
}