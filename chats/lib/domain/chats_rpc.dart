// Класс реализации методов описанных в chats.proto

import 'package:chats/Utils/utils.dart';
import 'package:chats/data/chats/chats.dart';
import 'package:chats/data/db.dart';
import 'package:chats/generated/chats.pbgrpc.dart';
import 'package:grpc/grpc.dart';

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

  @override
  Future<ListChatsDto> fetchAllChats(ServiceCall call, RequestDto request) {
    // TODO: implement fetchAllChats
    throw UnimplementedError();
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