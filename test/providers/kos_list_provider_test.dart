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

Kos _sampleKos(String id, String name) {
  return Kos(
    id: id,
    ownerId: 'owner-1',
    name: name,
    area: 'Singaraja',
    address: 'Jl. Ahmad Yani No. 1',
    description: 'Kos nyaman',
    pricePerMonth: 1000000,
    genderType: 'campur',
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
}

