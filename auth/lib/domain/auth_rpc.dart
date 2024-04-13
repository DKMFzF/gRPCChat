// Методы для работы с подключением auth.proto 

import 'dart:isolate';

import 'package:auth/data/db.dart';
import 'package:auth/data/user/user.dart';
import 'package:auth/env.dart';
import 'package:auth/generated/auth.pbgrpc.dart';
import 'package:auth/Utils/utils.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:stormberry/stormberry.dart';

class AuthRpc extends AuthRpcServiceBase {

  // Удаление пользователя из базы данных
  @override
  Future<ResponseDto> deleteUser(ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetaData(call);
    await db.users.deleteOne(id);
    return ResponseDto(message: 'User deleted');    
  }

  /* 
    Извлекает пользователя, используя предоставленные ServiceCall и RequestDto. 
    Возвращает Future<UserDto>.
  */
  @override
  Future<UserDto> fetchUser(ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetaData(call); // Извлечение id из метаданных клиента
    final user = await db.users.queryUser(id); // Выборка пользователя через id
    if (user == null) throw GrpcError.notFound('User not found');
    return Utils.convertUserDto(user);
  }

  /*
    Метод, который выполняет обновление токена. Принимает объект ServiceCall
    и объект TokensDto в качестве параметров. Возвращает объект TokensDto. 
  */
  @override
  Future<TokensDto> refreshToken(ServiceCall call, TokensDto request) async {
    // Проверки данных
    if (request.refreshToken.isEmpty) throw GrpcError.invalidArgument('Refresh Token not found');

    // Поиск пользователя по id
    final id = Utils.getIdFromToken(request.refreshToken);
    final user = await db.users.queryUser(id); // Зарос пользователя по id
    if (user == null) throw GrpcError.notFound('User not found');
    return _createTokens(user.id.toString());
  }

  /*
    Функция, которая выполняет вход пользователя, 
    проверяя входные данные, учетные данные пользователя
    и создавая токены при успешном входе. Принимает объект ServiceCall
    и объект UserDto в качестве параметров. Возвращает объект TokensDto.
  */
  @override
  Future<TokensDto> siginIn(ServiceCall call, UserDto request) async {
    // Проверки данных
    if (request.email.isEmpty || !Utils.isValidEmail(request.email)) throw GrpcError.invalidArgument('Email ERROR');
    if (request.password.isEmpty) throw GrpcError.invalidArgument('Password not found');

    // Поиск пользователя
    final hashPassword = Utils.getCashPassword(request.password);
    final users = await db.users.queryUsers(QueryParams(
      where: 'email=@email',
      values: {'email': Utils.encryptField(request.email)},
    ));

    // Проверка на наличие пользователя
    if (users.isEmpty) throw GrpcError.notFound('User not found');

    final user = users.first;

    // Проверка хэша пароля с паролем в базе данных
    if (hashPassword != user.password) throw GrpcError.unauthenticated('Wrong Password!');

    return _createTokens(user.id.toString()); // Создание токена
  }
  
  /*
    Функция, которая регистрирует пользователя, 
    используя данный вызов службы и пользовательские данные, 
    возвращая TokensDto
  */
  @override
  Future<TokensDto> siginUp(ServiceCall call, UserDto request) async {
    // Проверка данных
    if (request.email.isEmpty || !Utils.isValidEmail(request.email)) throw GrpcError.invalidArgument('Email ERROR');
    if (request.password.isEmpty || !Utils.isValidPassword(request.password)) throw GrpcError.invalidArgument('Password ERROR');
    if (request.username.isEmpty) throw GrpcError.invalidArgument('Username not fount');

    // Создание id пол пользователя при обращении к базе данных
    final id = await db.users.insertOne(UserInsertRequest(
      username: request.username, 
      email: Utils.encryptField(request.email),
      password: Utils.getCashPassword(request.password) // Применяем кэширование
    ));
    
    return _createTokens(id.toString()); // Создание токена
  }

  // Обновление данных пользователя
  @override
  Future<UserDto> updateUser(ServiceCall call, UserDto request) async {
    final id = Utils.getIdFromMetaData(call);
    await db.users.updateOne(
      UserUpdateRequest(
        id: id,
        username: request.username.isEmpty ? null : request.username,
        email: !Utils.isValidEmail(request.email) || request.email.isEmpty ? null : Utils.encryptField(request.email),
        password: request.password.isEmpty ? null : Utils.getCashPassword(request.password),
      ));

    final user = await db.users.queryUser(id);
    if (user == null) throw GrpcError.notFound('User not found');
    return Utils.convertUserDto(user);
  }
  
  // Поиск пользователя
  @override
  Future<ListUsersDto> findUser(ServiceCall call, FindDto request) async {
    final limit = int.tryParse(request.limit) ?? 100;
    final offset = int.tryParse(request.offset) ?? 0;
    final key = request.key;
    if (key.isEmpty) return ListUsersDto(users: []);
    final query = "username LIKE '%$key%'";
    final listUsers = await db.users.queryUsers(
      QueryParams(
        limit: limit,
        offset: offset,
        orderBy: key,
        where: query,
      )
    );
    return await Isolate.run(() => Utils.convertListUsersDto(listUsers));
  }

  /* 
    Генерирует TokensDto, содержащий токены доступа 
    и обновления для данного идентификатора пользователя.
  */
  TokensDto _createTokens(String id) {
    // Настройка токенов
    final accessTokenSet = JwtClaim(
      maxAge: Duration(hours: Env.accessTokenLife),
      otherClaims: {'user_id': id},);
    final refreshTokenClaim = JwtClaim(
      maxAge: Duration(hours: Env.refreshTokenLife),
      otherClaims: {'user_id': id},);

    // Генерация токенов
    return TokensDto(
      accessToken: issueJwtHS256(accessTokenSet, Env.sk),
      refreshToken: issueJwtHS256(refreshTokenClaim, Env.sk), 
    );
  }
}