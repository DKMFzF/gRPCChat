import 'package:auth/data/db.dart';
import 'package:auth/data/user/user.dart';
import 'package:auth/generated/auth.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/src/server/call.dart';

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

  @override
  Future<TokensDto> siginUp(ServiceCall call, UserDto request) async {
    // Проверка данных
    if (request.email.isEmpty) throw GrpcError.invalidArgument('Email not found');
    if (request.password.isEmpty) throw GrpcError.invalidArgument('Password not found');
    if (request.username.isEmpty) throw GrpcError.invalidArgument('Username not fount');

    // Создание id пользователя
    final id = await db.users.insertOne(UserInsertRequest(
      username: request.username, 
      email: request.email,
      password: request.password
    ));

    // Создание токенов
  }

  @override
  Future<UserDto> updateUser(ServiceCall call, UserDto request) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

}