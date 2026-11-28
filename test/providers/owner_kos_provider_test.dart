import 'package:flutter_test/flutter_test.dart';

import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

Kos _sampleKos({String id = 'kos-1', String ownerId = 'uid-1'}) => Kos(
      id: id,
      ownerId: ownerId,
      name: 'Kos Sejahtera',
      area: 'Singaraja',
      address: 'Jl. Udayana No. 10',
      description: 'Kos nyaman dan bersih',
      pricePerMonth: 1200000,
      genderType: 'campur',
      whatsappNumber: '081234567890',
    );

void main() {
  group('OwnerKosProvider Tests (US05, US06, US07)', () {
    test('US05-AC2: loadOwnerKos berhasil memuat daftar kos milik owner', () async {
      final repo = KosRepository();
      repo.setCrudHandlers(
        fetchByOwner: (ownerId) async => [_sampleKos(ownerId: ownerId)],
      );

      final provider = OwnerKosProvider(repository: repo);
      await provider.loadOwnerKos('uid-1');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.ownerKosList.length, 1);
      expect(provider.ownerKosList.first.name, 'Kos Sejahtera');
    });

    test('US05-AC2: loadOwnerKos menangani error koneksi dan mengisi errorMessage', () async {
      final repo = KosRepository();
      repo.setCrudHandlers(
        fetchByOwner: (ownerId) async => throw Exception('Network error'),
      );

      final provider = OwnerKosProvider(repository: repo);
      await provider.loadOwnerKos('uid-1');

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNotNull);
      expect(provider.ownerKosList, isEmpty);
    });

    test('US05-AC1: addKos berhasil memanggil repository insert dan return true', () async {
      final repo = KosRepository();
      Map<String, dynamic>? insertedData;
      repo.setCrudHandlers(
        insert: (data) async => insertedData = data,
      );

      final provider = OwnerKosProvider(repository: repo);
      final success = await provider.addKos({
        'owner_id': 'uid-1',
        'name': 'Kos Baru',
        'price_per_month': 1000000,
      });

      expect(success, isTrue);
      expect(provider.errorMessage, isNull);
      expect(insertedData?['name'], 'Kos Baru');
    });

    test('US05-AC1: addKos gagal dan mengisi errorMessage yang ramah', () async {
      final repo = KosRepository();
      repo.setCrudHandlers(
        insert: (data) async => throw Exception('DB error'),
      );

      final provider = OwnerKosProvider(repository: repo);
      final success = await provider.addKos({
        'owner_id': 'uid-1',
        'name': 'Kos Gagal',
      });

      expect(success, isFalse);
      expect(provider.errorMessage, 'Gagal menambah kos. Silakan coba lagi.');
    });

    test('US06-AC1: updateKos berhasil memanggil repository update dan return true', () async {
      final repo = KosRepository();
      String? updatedId;
      Map<String, dynamic>? updatedData;
      repo.setCrudHandlers(
        update: (id, data) async {
          updatedId = id;
          updatedData = data;
        },
      );

      final provider = OwnerKosProvider(repository: repo);
      final success = await provider.updateKos('kos-1', {'price_per_month': 1500000});

      expect(success, isTrue);
      expect(provider.errorMessage, isNull);
      expect(updatedId, 'kos-1');
      expect(updatedData?['price_per_month'], 1500000);
    });

    test('US06-AC1: updateKos gagal dan mengisi errorMessage yang ramah', () async {
      final repo = KosRepository();
      repo.setCrudHandlers(
        update: (id, data) async => throw Exception('Update failed'),
      );

      final provider = OwnerKosProvider(repository: repo);
      final success = await provider.updateKos('kos-1', {});

      expect(success, isFalse);
      expect(provider.errorMessage, 'Gagal memperbarui kos. Silakan coba lagi.');
    });

    test('US07-AC2: deleteKos berhasil memanggil repository delete dan menghapus dari list', () async {
      final repo = KosRepository();
      String? deletedId;
      repo.setCrudHandlers(
        fetchByOwner: (ownerId) async => [_sampleKos(id: 'kos-1', ownerId: ownerId)],
        delete: (id) async => deletedId = id,
      );

      final provider = OwnerKosProvider(repository: repo);
      await provider.loadOwnerKos('uid-1');
      expect(provider.ownerKosList.length, 1);

      final success = await provider.deleteKos('kos-1');

      expect(success, isTrue);
      expect(deletedId, 'kos-1');
      expect(provider.ownerKosList, isEmpty);
      expect(provider.errorMessage, isNull);
    });

    test('US07-AC2: deleteKos gagal dan mengisi errorMessage yang ramah', () async {
      final repo = KosRepository();
      repo.setCrudHandlers(
        delete: (id) async => throw Exception('Delete error'),
      );

      final provider = OwnerKosProvider(repository: repo);
      final success = await provider.deleteKos('kos-1');

      expect(success, isFalse);
      expect(provider.errorMessage, 'Gagal menghapus kos. Silakan coba lagi.');
    });
  });
}
