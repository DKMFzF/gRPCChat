import 'package:chats/data/message/message.dart';
import 'package:stormberry/stormberry.dart';

part 'chats.schema.dart';

@Model()
abstract class Chats {
  @PrimaryKey()
  @AutoIncrement()
  int get id;
  
  String get name;
  String get authorId;
  List<Message> get message;
}