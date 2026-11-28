import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_repository.dart';

/// State provider for the public boarding house list (`US01`, `US03`).
class KosListProvider extends ChangeNotifier {
  KosListProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  static const String defaultErrorMessage =
      'Gagal memuat data, periksa koneksi internet Anda';
  static const String emptyFilterMessage =
      'Tidak ada kos yang sesuai dengan kriteria pencarian';

  final KosRepository _repository;

  List<Kos> _kosList = const [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  int? _maxPrice;
  bool _filterWifi = false;
  bool _filterAc = false;
  bool _filterPrivateBathroom = false;
  bool _filterIncludesElectricity = false;

  /// Filtered list of boarding houses matching current search and filter criteria.
  List<Kos> get kosList {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _kosList.where((kos) {
      if (query.isNotEmpty) {
        final matchesName = kos.name.toLowerCase().contains(query);
        final matchesArea = kos.area.toLowerCase().contains(query);
        if (!matchesName && !matchesArea) return false;
      }
      if (_maxPrice != null && kos.pricePerMonth > _maxPrice!) {
        return false;
      }
      if (_filterWifi && !kos.hasWifi) return false;
      if (_filterAc && !kos.hasAc) return false;
      if (_filterPrivateBathroom && !kos.hasPrivateBathroom) return false;
      if (_filterIncludesElectricity && !kos.includesElectricity) return false;
      return true;
    }).toList();

    return List.unmodifiable(filtered);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && !hasError && _kosList.isEmpty;
  bool get isFilteredEmpty =>
      !_isLoading && !hasError && _kosList.isNotEmpty && kosList.isEmpty;

  String get searchQuery => _searchQuery;
  int? get maxPrice => _maxPrice;
  bool get filterWifi => _filterWifi;
  bool get filterAc => _filterAc;
  bool get filterPrivateBathroom => _filterPrivateBathroom;
  bool get filterIncludesElectricity => _filterIncludesElectricity;
  bool get hasActiveFilter =>
      _searchQuery.trim().isNotEmpty ||
      _maxPrice != null ||
      _filterWifi ||
      _filterAc ||
      _filterPrivateBathroom ||
      _filterIncludesElectricity;

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

  /// Updates the case-insensitive search query on boarding house name and area (`US03-AC1`).
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Applies maximum price and facility filters (`US03-AC2`, `US03-AC3`).
  void applyFilters({
    int? maxPrice,
    bool wifi = false,
    bool ac = false,
    bool privateBathroom = false,
    bool includesElectricity = false,
  }) {
    _maxPrice = maxPrice;
    _filterWifi = wifi;
    _filterAc = ac;
    _filterPrivateBathroom = privateBathroom;
    _filterIncludesElectricity = includesElectricity;
    notifyListeners();
  }

  /// Clears all price and facility filters while keeping the current search query.
  void resetFilters() {
    _maxPrice = null;
    _filterWifi = false;
    _filterAc = false;
    _filterPrivateBathroom = false;
    _filterIncludesElectricity = false;
    notifyListeners();
  }
}
