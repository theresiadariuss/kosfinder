import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_repository.dart';

/// Manages CRUD operations for boarding houses owned by the current authenticated user (US05, US06, US07).
class OwnerKosProvider extends ChangeNotifier {
  OwnerKosProvider({required this.repository});

  final KosRepository repository;

  List<Kos> _ownerKosList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Kos> get ownerKosList => List.unmodifiable(_ownerKosList);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads all kos belonging to [ownerId] from Supabase (US05-AC2).
  Future<void> loadOwnerKos(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _ownerKosList = await repository.fetchByOwner(ownerId);
    } catch (_) {
      _errorMessage = 'Gagal memuat data kos Anda. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inserts a new kos record (US05-AC1).
  Future<bool> addKos(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.insert(data);
      return true;
    } catch (_) {
      _errorMessage = 'Gagal menambah kos. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing kos record by [id] (US06-AC1).
  Future<bool> updateKos(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.update(id, data);
      return true;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui kos. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a kos record by [id] (US07-AC2).
  Future<bool> deleteKos(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.delete(id);
      _ownerKosList.removeWhere((k) => k.id == id);
      return true;
    } catch (_) {
      _errorMessage = 'Gagal menghapus kos. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
