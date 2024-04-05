// Класс реализации методов описанных в chats.proto

import 'dart:isolate';

import 'package:chats/Utils/utils.dart';
import 'package:chats/data/chats/chats.dart';
import 'package:chats/data/db.dart';
import 'package:chats/generated/chats.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:stormberry/stormberry.dart';

class ChatRpc extends ChatsRpcServiceBase {
  @override
  Future<ResponseDto> createChat(ServiceCall call, ChatDto request) async {
    final id = Utils.getIdFromMetaData(call); 
    if (request.name.isEmpty) throw GrpcError.invalidArgument('Not found chat name'); 
    await db.chatses.insertOne(
      ChatsInsertRequest(
        name: request.name, 
        authorId: id.toString())
    );
    return ResponseDto(message: 'Chat created');
  }

  @override
  Future<ResponseDto> deleteChat(ServiceCall call, ChatDto request) {
    // TODO: implement deleteChat
    throw UnimplementedError();
  }

  @override
  Future<ResponseDto> deleteMessage(ServiceCall call, MessageDto request) {
    // TODO: implement deleteMessage
    throw UnimplementedError();
  }

  // Метод для получения всех чатов пользователя
  @override
  Future<ListChatsDto> fetchAllChats(
      ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetaData(call);
    final listChats = await db.chatses.queryChatses(QueryParams( // Перебор всех значений в SQL
      where: 'author_id=@id',
      values: {'id': id},
    ));
    if (listChats.isEmpty) return ListChatsDto(chats: []);
    return await Isolate.run(() => Utils.parsChats(listChats)); // Разобраться
  }
  
  @override
  Future<ChatDto> fetchChats(ServiceCall call, ChatDto request) {
    // TODO: implement fetchChats
    throw UnimplementedError();
  }

  @override
  Stream<MessageDto> listenChat(ServiceCall call, ChatDto request) {
    // TODO: implement listenChat
    throw UnimplementedError();
  }

  @override
  Future<ResponseDto> sendMessage(ServiceCall call, MessageDto request) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

}