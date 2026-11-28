import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_list_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class _FakeKosRepository implements KosRepository {
  _FakeKosRepository({
    this.items = const [],
    this.shouldThrow = false,
  });

  List<Kos> items;
  bool shouldThrow;
  int fetchAllCalls = 0;

  @override
  Future<List<Kos>> fetchAll() async {
    fetchAllCalls++;
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return items;
  }

  @override
  Future<Kos?> fetchById(String id) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

Kos _sampleKos(
  String id,
  String name, {
  String area = 'Singaraja',
  int pricePerMonth = 1000000,
  bool hasWifi = false,
  bool hasAc = false,
  bool hasPrivateBathroom = false,
  bool includesElectricity = false,
}) {
  return Kos(
    id: id,
    ownerId: 'owner-1',
    name: name,
    area: area,
    address: 'Jl. Ahmad Yani No. 1',
    description: 'Kos nyaman',
    pricePerMonth: pricePerMonth,
    genderType: 'campur',
    hasWifi: hasWifi,
    hasAc: hasAc,
    hasPrivateBathroom: hasPrivateBathroom,
    includesElectricity: includesElectricity,
    whatsappNumber: '081234567890',
  );
}

void main() {
  group('KosListProvider Tests', () {
    test('initial state is empty, not loading, and has no error', () {
      final provider = KosListProvider(repository: _FakeKosRepository());

      expect(provider.kosList, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.isEmpty, isTrue);
      expect(provider.isFilteredEmpty, isFalse);
      expect(provider.hasActiveFilter, isFalse);
    });

    test('loadKos populates kosList and toggles loading state (US01-AC1)', () async {
      final sampleItems = [
        _sampleKos('1', 'Kos Melati'),
        _sampleKos('2', 'Kos Mawar'),
      ];
      final repo = _FakeKosRepository(items: sampleItems);
      final provider = KosListProvider(repository: repo);

      final loadingStates = <bool>[];
      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      await provider.loadKos();

      expect(loadingStates, [true, false]);
      expect(provider.kosList.length, 2);
      expect(provider.kosList.first.name, 'Kos Melati');
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isFalse);
      expect(repo.fetchAllCalls, 1);
    });

    test('loadKos handles empty dataset cleanly (US01-AC2)', () async {
      final repo = _FakeKosRepository(items: []);
      final provider = KosListProvider(repository: repo);

      await provider.loadKos();

      expect(provider.kosList, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isTrue);
    });

    test('loadKos sets friendly error message on failure (US01-AC3)', () async {
      final repo = _FakeKosRepository(shouldThrow: true);
      final provider = KosListProvider(repository: repo);

      await provider.loadKos();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isTrue);
      expect(
        provider.errorMessage,
        'Gagal memuat data, periksa koneksi internet Anda',
      );
      expect(provider.isEmpty, isFalse);
    });

    test('retry reloads data and clears previous error (US01-AC3)', () async {
      final repo = _FakeKosRepository(shouldThrow: true);
      final provider = KosListProvider(repository: repo);

      await provider.loadKos();
      expect(provider.hasError, isTrue);

      repo.shouldThrow = false;
      repo.items = [_sampleKos('1', 'Kos Anggrek')];

      await provider.retry();

      expect(repo.fetchAllCalls, 2);
      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Anggrek');
    });
  });

  group('KosListProvider Search & Filter Tests (US03)', () {
    late KosListProvider provider;

    setUp(() async {
      final repo = _FakeKosRepository(
        items: [
          _sampleKos(
            '1',
            'Kos Melati Singaraja',
            area: 'Banyuasri',
            pricePerMonth: 900000,
            hasWifi: true,
            hasAc: true,
          ),
          _sampleKos(
            '2',
            'Kos Mawar',
            area: 'Singaraja',
            pricePerMonth: 1500000,
            hasWifi: true,
            hasPrivateBathroom: true,
          ),
          _sampleKos(
            '3',
            'Kos Kenanga',
            area: 'Denpasar',
            pricePerMonth: 2000000,
            hasWifi: true,
            hasAc: true,
            hasPrivateBathroom: true,
            includesElectricity: true,
          ),
        ],
      );
      provider = KosListProvider(repository: repo);
      await provider.loadKos();
    });

    test('setSearchQuery filters case-insensitively by name and area (US03-AC1)', () {
      provider.setSearchQuery('singaraja');
      expect(provider.kosList.map((k) => k.id), ['1', '2']);
      expect(provider.hasActiveFilter, isTrue);

      provider.setSearchQuery('SINGARAJA');
      expect(provider.kosList.map((k) => k.id), ['1', '2']);

      provider.setSearchQuery('  denpasar ');
      expect(provider.kosList.map((k) => k.id), ['3']);

      provider.setSearchQuery('');
      expect(provider.kosList.length, 3);
    });

    test('applyFilters filters by maxPrice inclusive (US03-AC2)', () {
      provider.applyFilters(maxPrice: 1500000);

      expect(provider.maxPrice, 1500000);
      expect(provider.kosList.map((k) => k.id), ['1', '2']);
      expect(provider.isFilteredEmpty, isFalse);
    });

    test('applyFilters requires all selected facilities (US03-AC3)', () {
      provider.applyFilters(wifi: true, ac: true);

      expect(provider.filterWifi, isTrue);
      expect(provider.filterAc, isTrue);
      expect(provider.kosList.map((k) => k.id), ['1', '3']);

      provider.applyFilters(
        wifi: true,
        ac: true,
        privateBathroom: true,
        includesElectricity: true,
      );
      expect(provider.kosList.map((k) => k.id), ['3']);
    });

    test('combined search and filter returns empty and sets isFilteredEmpty (US03-AC4)', () {
      provider.setSearchQuery('Singaraja');
      provider.applyFilters(maxPrice: 800000, wifi: true);

      expect(provider.kosList, isEmpty);
      expect(provider.isEmpty, isFalse);
      expect(provider.isFilteredEmpty, isTrue);
      expect(
        KosListProvider.emptyFilterMessage,
        'Tidak ada kos yang sesuai dengan kriteria pencarian',
      );
    });

    test('resetFilters clears price and facility filters while keeping search query', () {
      provider.setSearchQuery('Singaraja');
      provider.applyFilters(maxPrice: 1000000, wifi: true, ac: true);
      expect(provider.kosList.map((k) => k.id), ['1']);

      provider.resetFilters();
      expect(provider.maxPrice, isNull);
      expect(provider.filterWifi, isFalse);
      expect(provider.filterAc, isFalse);
      expect(provider.kosList.map((k) => k.id), ['1', '2']);
    });
  });
}
