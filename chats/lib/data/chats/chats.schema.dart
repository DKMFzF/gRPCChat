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

  Future<ShortChatsView?> queryShortView(int id);
  Future<List<ShortChatsView>> queryShortViews([QueryParams? params]);
  Future<FullChatsView?> queryFullView(int id);
  Future<List<FullChatsView>> queryFullViews([QueryParams? params]);
}

class _ChatsRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<ChatsInsertRequest>,
        RepositoryUpdateMixin<ChatsUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements ChatsRepository {
  _ChatsRepository(super.db) : super(tableName: 'chatses', keyName: 'id');

  @override
  Future<ShortChatsView?> queryShortView(int id) {
    return queryOne(id, ShortChatsViewQueryable());
  }

  @override
  Future<List<ShortChatsView>> queryShortViews([QueryParams? params]) {
    return queryMany(ShortChatsViewQueryable(), params);
  }

  @override
  Future<FullChatsView?> queryFullView(int id) {
    return queryOne(id, FullChatsViewQueryable());
  }

  @override
  Future<List<FullChatsView>> queryFullViews([QueryParams? params]) {
    return queryMany(FullChatsViewQueryable(), params);
  }

  @override
  Future<List<int>> insert(List<ChatsInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var values = QueryValues();
    var rows = await db.query(
      'INSERT INTO "chatses" ( "name", "author_id", "member_id" )\n'
      'VALUES ${requests.map((r) => '( ${values.add(r.name)}:text, ${values.add(r.authorId)}:text, ${values.add(r.memberId)}:text )').join(', ')}\n'
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
      'SET "name" = COALESCE(UPDATED."name", "chatses"."name"), "author_id" = COALESCE(UPDATED."author_id", "chatses"."author_id"), "member_id" = COALESCE(UPDATED."member_id", "chatses"."member_id")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${values.add(r.id)}:int8::int8, ${values.add(r.name)}:text::text, ${values.add(r.authorId)}:text::text, ${values.add(r.memberId)}:text::text )').join(', ')} )\n'
      'AS UPDATED("id", "name", "author_id", "member_id")\n'
      'WHERE "chatses"."id" = UPDATED."id"',
      values.values,
    );
  }
}

class ChatsInsertRequest {
  ChatsInsertRequest({
    required this.name,
    required this.authorId,
    this.memberId,
  });

  final String name;
  final String authorId;
  final String? memberId;
}

class ChatsUpdateRequest {
  ChatsUpdateRequest({
    required this.id,
    this.name,
    this.authorId,
    this.memberId,
  });

  final int id;
  final String? name;
  final String? authorId;
  final String? memberId;
}

class ShortChatsViewQueryable extends KeyedViewQueryable<ShortChatsView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => TextEncoder.i.encode(key);

  @override
  String get query => 'SELECT "chatses".*'
      'FROM "chatses"';

  @override
  String get tableAlias => 'chatses';

  @override
  ShortChatsView decode(TypedMap map) => ShortChatsView(
      id: map.get('id'),
      name: map.get('name'),
      authorId: map.get('author_id'),
      memberId: map.getOpt('member_id'));
}

class ShortChatsView {
  ShortChatsView({
    required this.id,
    required this.name,
    required this.authorId,
    this.memberId,
  });

  final int id;
  final String name;
  final String authorId;
  final String? memberId;
}

class FullChatsViewQueryable extends KeyedViewQueryable<FullChatsView, int> {
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
  FullChatsView decode(TypedMap map) => FullChatsView(
      id: map.get('id'),
      name: map.get('name'),
      authorId: map.get('author_id'),
      memberId: map.getOpt('member_id'),
      message: map.getListOpt('message', MessageViewQueryable().decoder) ?? const []);
}

class FullChatsView {
  FullChatsView({
    required this.id,
    required this.name,
    required this.authorId,
    this.memberId,
    required this.message,
  });

  final int id;
  final String name;
  final String authorId;
  final String? memberId;
  final List<MessageView> message;
}
