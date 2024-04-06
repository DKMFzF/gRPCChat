// Класс для утилит

import 'package:chats/data/chats/chats.dart';
import 'package:chats/env.dart';
import 'package:chats/generated/chats.pb.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class Utils {
  /*  
    Изъятие id из токена
    @param: String token - токен для извлечения id
    return: значение: id пользователя из токена
    Exception: GrpcError в случае отсутствия id в токене
  */
  static int getIdFromToken(String token) {

    // Изъятие id из токена
    final jwtClaim = verifyJwtHS256Signature(token, Env.sk);
    final id = int.tryParse(jwtClaim['user_id']);

    // Проверерка на получение id из токена
    if (id == null) throw GrpcError.dataLoss('User Id not found');
    return id;
  }

  /* 
    Извлекает идентификатор из метаданных клиента 
    в данном объекте ServiceCall, используя токен доступа. 
    Возвращает идентификатор, полученный из токена.
  */
  static int getIdFromMetaData(ServiceCall serviceCall) {
    final accessToken = serviceCall.clientMetadata?['access_token'] ?? ''; 
    return getIdFromToken(accessToken);
  }

  // Метод преобразования списка ChatsView в ListChatsDto (Разобратся как работает)
  static ListChatsDto parsChats(List<ChatsView> list) {
    try {
      return ListChatsDto(chats: [
        ...list.map(
          (chat) => ChatDto(
            author: chat.authorId, id: chat.id.toString(), name: chat.name))
      ]);
    } catch(_) {
      rethrow;
    }
  }
}