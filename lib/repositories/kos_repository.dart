import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

/// Repository for querying boarding house (`kos`) data from Supabase.
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

