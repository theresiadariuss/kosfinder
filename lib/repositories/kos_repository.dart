import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

/// Repository for querying and mutating boarding house (`kos`) data from Supabase.
class KosRepository {
  KosRepository([this._client]);

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  /// Fetches all public boarding houses ordered by newest first.
  Future<List<Kos>> fetchAll() async {
    final response = await _supabase
        .from('kos')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => Kos.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  /// Fetches a single boarding house by [id], or returns `null` if not found.
  Future<Kos?> fetchById(String id) async {
    final response = await _supabase
        .from('kos')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Kos.fromJson(Map<String, dynamic>.from(response));
  }
}

final _crudExpando = Expando<_KosCrudHandlers>();

class _KosCrudHandlers {
  _KosCrudHandlers({
    this.fetchByOwner,
    this.insert,
    this.update,
    this.delete,
  });

  Future<List<Kos>> Function(String ownerId)? fetchByOwner;
  Future<void> Function(Map<String, dynamic> data)? insert;
  Future<void> Function(String id, Map<String, dynamic> data)? update;
  Future<void> Function(String id)? delete;
}

/// Extension providing CRUD mutation methods on [KosRepository] (US05, US06, US07).
extension KosRepositoryCrud on KosRepository {
  /// Injects custom handlers for testing without breaking sub-typing.
  void setCrudHandlers({
    Future<List<Kos>> Function(String ownerId)? fetchByOwner,
    Future<void> Function(Map<String, dynamic> data)? insert,
    Future<void> Function(String id, Map<String, dynamic> data)? update,
    Future<void> Function(String id)? delete,
  }) {
    _crudExpando[this] = _KosCrudHandlers(
      fetchByOwner: fetchByOwner,
      insert: insert,
      update: update,
      delete: delete,
    );
  }

  /// Fetches all kos owned by [ownerId] (US05-AC2).
  Future<List<Kos>> fetchByOwner(String ownerId) async {
    final custom = _crudExpando[this]?.fetchByOwner;
    if (custom != null) return custom(ownerId);

    final response = await _supabase
        .from('kos')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => Kos.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  /// Inserts a new kos record (US05-AC1).
  Future<void> insert(Map<String, dynamic> data) async {
    final custom = _crudExpando[this]?.insert;
    if (custom != null) return custom(data);

    await _supabase.from('kos').insert(data);
  }

  /// Updates an existing kos record by [id] (US06-AC1).
  Future<void> update(String id, Map<String, dynamic> data) async {
    final custom = _crudExpando[this]?.update;
    if (custom != null) return custom(id, data);

    await _supabase.from('kos').update(data).eq('id', id);
  }

  /// Deletes a kos record by [id] (US07-AC2).
  Future<void> delete(String id) async {
    final custom = _crudExpando[this]?.delete;
    if (custom != null) return custom(id);

    await _supabase.from('kos').delete().eq('id', id);
  }
}
