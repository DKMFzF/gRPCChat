// ignore_for_file: annotate_overrides

part of 'chats.dart';

extension ChatsRepositories on Database {
  ChatsRepository get chatses => ChatsRepository._(this);
}

abstract class ChatsRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<ChatsInsertRequest>,
        ModelRepositoryUpdate<ChatsUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory ChatsRepository._(Database db) = _ChatsRepository;

  Future<ChatsView?> queryChats(int id);
  Future<List<ChatsView>> queryChatses([QueryParams? params]);
}

class _ChatsRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<ChatsInsertRequest>,
        RepositoryUpdateMixin<ChatsUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements ChatsRepository {
  _ChatsRepository(super.db) : super(tableName: 'chatses', keyName: 'id');

  @override
  Future<ChatsView?> queryChats(int id) {
    return queryOne(id, ChatsViewQueryable());
  }

  @override
  Future<List<ChatsView>> queryChatses([QueryParams? params]) {
    return queryMany(ChatsViewQueryable(), params);
  }

  @override
  Future<List<int>> insert(List<ChatsInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var values = QueryValues();
    var rows = await db.query(
      'INSERT INTO "chatses" ( "name", "author_id" )\n'
      'VALUES ${requests.map((r) => '( ${values.add(r.name)}:text, ${values.add(r.authorId)}:text )').join(', ')}\n'
      'RETURNING "id"',
      values.values,
    );
    var result = rows.map<int>((r) => TextEncoder.i.decode(r.toColumnMap()['id'])).toList();

    return result;
  }

  @override
  Future<void> update(List<ChatsUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.query(
      'UPDATE "chatses"\n'
      'SET "name" = COALESCE(UPDATED."name", "chatses"."name"), "author_id" = COALESCE(UPDATED."author_id", "chatses"."author_id")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${values.add(r.id)}:int8::int8, ${values.add(r.name)}:text::text, ${values.add(r.authorId)}:text::text )').join(', ')} )\n'
      'AS UPDATED("id", "name", "author_id")\n'
      'WHERE "chatses"."id" = UPDATED."id"',
      values.values,
    );
  }
}

class ChatsInsertRequest {
  ChatsInsertRequest({
    required this.name,
    required this.authorId,
  });

  final String name;
  final String authorId;
}

class ChatsUpdateRequest {
  ChatsUpdateRequest({
    required this.id,
    this.name,
    this.authorId,
  });

  final int id;
  final String? name;
  final String? authorId;
}

class ChatsViewQueryable extends KeyedViewQueryable<ChatsView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => TextEncoder.i.encode(key);

  @override
  String get query => 'SELECT "chatses".*, "message"."data" as "message"'
      'FROM "chatses"'
      'LEFT JOIN ('
      '  SELECT "messages"."chats_id",'
      '    to_jsonb(array_agg("messages".*)) as data'
      '  FROM (${MessageViewQueryable().query}) "messages"'
      '  GROUP BY "messages"."chats_id"'
      ') "message"'
      'ON "chatses"."id" = "message"."chats_id"';

  @override
  String get tableAlias => 'chatses';

  @override
  ChatsView decode(TypedMap map) => ChatsView(
      id: map.get('id'),
      name: map.get('name'),
      authorId: map.get('author_id'),
      message: map.getListOpt('message', MessageViewQueryable().decoder) ?? const []);
}

class ChatsView {
  ChatsView({
    required this.id,
    required this.name,
    required this.authorId,
    required this.message,
  });

  final int id;
  final String name;
  final String authorId;
  final List<MessageView> message;
}
