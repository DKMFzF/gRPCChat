// Класс ORM модели Chats

import 'package:chats/data/message/message.dart';
import 'package:stormberry/stormberry.dart';

part 'chats.schema.dart';

@Model(
  views: [#Short, #Full] // Схемы
)
abstract class Chats {
  @PrimaryKey()
  @AutoIncrement()
  int get id;
  
  String get name;
  String get authorId;

  @HiddenIn(#Short) // Скрытие имен в схеме
  List<Message> get message;
}