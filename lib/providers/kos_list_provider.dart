import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_repository.dart';

/// State provider for the public boarding house list (`US01`).
class KosListProvider extends ChangeNotifier {
  KosListProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  static const String defaultErrorMessage =
      'Gagal memuat data, periksa koneksi internet Anda';

  final KosRepository _repository;

  List<Kos> _kosList = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Kos> get kosList => List.unmodifiable(_kosList);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && !hasError && _kosList.isEmpty;

  /// Loads all boarding houses from the repository.
  Future<void> loadKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kosList = await _repository.fetchAll();
    } catch (_) {
      _errorMessage = defaultErrorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retries loading the boarding house list after an error.
  Future<void> retry() => loadKos();
}

