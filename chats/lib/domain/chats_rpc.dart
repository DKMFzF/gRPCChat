// Класс реализации методов описанных в chats.proto

import 'dart:async';
import 'dart:isolate';

import 'package:chats/Utils/utils.dart';
import 'package:chats/data/chats/chats.dart';
import 'package:chats/data/db.dart';
import 'package:chats/data/message/message.dart';
import 'package:chats/generated/chats.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:protobuf/protobuf.dart';
import 'package:stormberry/stormberry.dart';

class ChatRpc extends ChatsRpcServiceBase {

  final StreamController<MessageDto> _streamController = StreamController.broadcast();

  @override
  Future<ResponseDto> createChat(ServiceCall call, ChatDto request) async {
    final id = Utils.getIdFromMetaData(call); 
    if (request.name.isEmpty) throw GrpcError.invalidArgument('Not found chat name'); 
    if (request.memberId.isEmpty) throw GrpcError.invalidArgument('Not found memberId');
    if (request.memberId == id.toString()) throw GrpcError.notFound('You can not add yourself');
    await db.chatses.insertOne(
      ChatsInsertRequest(
        name: request.name, 
        authorId: id.toString(),
        memberId: request.memberId)
    );
    return ResponseDto(message: 'Chat created');
  }

  // Метод для удаления чата
  @override
  Future<ResponseDto> deleteChat(ServiceCall call, ChatDto request) async {
    final authorId = Utils.getIdFromMetaData(call);
    final chatId = int.tryParse(request.id);
    if (chatId == null) throw GrpcError.invalidArgument('Not found chat id');
    final chat = await db.chatses.queryShortView(chatId);
    if (chat == null) throw GrpcError.notFound('Chat not found');  
    if (chat.authorId == authorId.toString()) {
      await db.chatses.deleteOne(chatId);
      return ResponseDto(message: 'Chat deleted');
    } else {
      throw GrpcError.permissionDenied();
    }
  }

  // Метод для удалений сообщений из чата
  @override
  Future<ResponseDto> deleteMessage(ServiceCall call, MessageDto request) async {
    final messageId = int.tryParse(request.id);
    if (messageId == null) throw GrpcError.invalidArgument('Not found message id');
    final message = await db.messages.queryMessage(messageId);
    if (message == null) throw GrpcError.invalidArgument('Message not found');
    final userId = Utils.getIdFromMetaData(call);
    if (message.authorId == userId.toString()) {
      await db.messages.deleteOne(messageId);
      return ResponseDto(message: 'Message deleted');
    } else {
      throw GrpcError.permissionDenied();
    }
  }

  // Метод для получения всех чатов пользователя
  @override
  Future<ListChatsDto> fetchAllChats(ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetaData(call);
    final listChats = await db.chatses.queryShortViews(QueryParams( // Перебор всех значений в SQL
      where: 'author_id=@id OR member_id=@id',
      values: {'id': id},
    ));
    if (listChats.isEmpty) return ListChatsDto(chats: []);
    return await Isolate.run(() => Utils.parsChats(listChats)); // Изолирующий поток для парсинга данных
  }
  
  // Получение чата из базы данных
  @override
  Future<ChatDto> fetchChats(ServiceCall call, ChatDto request) async {
    final chatId = int.tryParse(request.id);
    if (chatId == null) throw GrpcError.notFound('Chat not found');
    final chat = await db.chatses.queryFullView(chatId);
    final authorId = Utils.getIdFromMetaData(call);
    if (chat == null) throw GrpcError.notFound('Chat not found');  
    if (chat.authorId == authorId.toString() || chat.memberId == authorId.toString()) {
      return await Isolate.run(() => Utils.parsChatsDto(chat));
    } else {
      throw GrpcError.permissionDenied();
    } 
  }

  // Получение всех сообщений из чата
  @override
  Stream<MessageDto> listenChat(ServiceCall call, ChatDto request) async* {
    if (request.id.isEmpty) throw GrpcError.invalidArgument('Not found chat id');
    yield* _streamController.stream.where((event) => event.chatId == request.id);
  }

  // Метод для отправки сообщений в чат (body - сообщение)
  @override
  Future<ResponseDto> sendMessage(ServiceCall call, MessageDto request) async {
    final authorId = Utils.getIdFromMetaData(call);
    final chatId = int.tryParse(request.chatId);
    if (chatId == null) throw GrpcError.notFound('Chat not found'); 
    if (request.body.isEmpty) throw GrpcError.invalidArgument('Body not found');
    final id = await db.messages.insertOne(
      MessageInsertRequest(
        body: request.body, 
        authorId: authorId.toString(), 
        chatsId: chatId,
    ));
    _streamController.add(request.deepCopy()..authorId = authorId.toString()..id = id.toString());
    return ResponseDto(message: 'Message sent');
  }
}