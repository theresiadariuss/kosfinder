import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';

void main() {
  group('Kos Model Tests', () {
    final sampleJson = <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'owner_id': '22222222-2222-2222-2222-222222222222',
      'name': 'Kos Melati Singaraja',
      'area': 'Singaraja',
      'address': 'Jl. Ahmad Yani No. 12, Singaraja',
      'description': 'Kos nyaman dekat kampus Undiksha.',
      'price_per_month': 1500000,
      'gender_type': 'putri',
      'has_wifi': true,
      'has_ac': true,
      'has_private_bathroom': false,
      'includes_electricity': true,
      'whatsapp_number': '081234567890',
      'created_at': '2026-01-10T08:30:00.000Z',
      'updated_at': '2026-01-11T09:00:00.000Z',
    };

    test('fromJson parses complete PostgreSQL JSON accurately', () {
      final kos = Kos.fromJson(sampleJson);

      expect(kos.id, '11111111-1111-1111-1111-111111111111');
      expect(kos.ownerId, '22222222-2222-2222-2222-222222222222');
      expect(kos.name, 'Kos Melati Singaraja');
      expect(kos.area, 'Singaraja');
      expect(kos.address, 'Jl. Ahmad Yani No. 12, Singaraja');
      expect(kos.description, 'Kos nyaman dekat kampus Undiksha.');
      expect(kos.pricePerMonth, 1500000);
      expect(kos.genderType, 'putri');
      expect(kos.hasWifi, isTrue);
      expect(kos.hasAc, isTrue);
      expect(kos.hasPrivateBathroom, isFalse);
      expect(kos.includesElectricity, isTrue);
      expect(kos.whatsappNumber, '081234567890');
      expect(kos.createdAt, DateTime.parse('2026-01-10T08:30:00.000Z'));
      expect(kos.updatedAt, DateTime.parse('2026-01-11T09:00:00.000Z'));
    });

    test('fromJson handles missing or null optional fields safely', () {
      final kos = Kos.fromJson(<String, dynamic>{});

      expect(kos.id, '');
      expect(kos.ownerId, '');
      expect(kos.name, '');
      expect(kos.area, '');
      expect(kos.address, '');
      expect(kos.description, '');
      expect(kos.pricePerMonth, 0);
      expect(kos.genderType, 'campur');
      expect(kos.hasWifi, isFalse);
      expect(kos.hasAc, isFalse);
      expect(kos.hasPrivateBathroom, isFalse);
      expect(kos.includesElectricity, isFalse);
      expect(kos.whatsappNumber, '');
      expect(kos.createdAt, isNull);
      expect(kos.updatedAt, isNull);
    });

    test('toJson serializes snake_case fields for Supabase', () {
      final kos = Kos.fromJson(sampleJson);

      final jsonWithoutId = kos.toJson();
      expect(jsonWithoutId.containsKey('id'), isFalse);
      expect(jsonWithoutId['owner_id'], '22222222-2222-2222-2222-222222222222');
      expect(jsonWithoutId['name'], 'Kos Melati Singaraja');
      expect(jsonWithoutId['price_per_month'], 1500000);
      expect(jsonWithoutId['gender_type'], 'putri');
      expect(jsonWithoutId['has_wifi'], isTrue);
      expect(jsonWithoutId['has_private_bathroom'], isFalse);
      expect(jsonWithoutId['whatsapp_number'], '081234567890');

      final jsonWithId = kos.toJson(includeId: true);
      expect(jsonWithId['id'], '11111111-1111-1111-1111-111111111111');
    });

    test('formattedPrice and formattedPricePerMonth format Rupiah correctly', () {
      final kos1 = Kos.fromJson({...sampleJson, 'price_per_month': 1500000});
      expect(kos1.formattedPrice, 'Rp 1.500.000');
      expect(kos1.formattedPricePerMonth, 'Rp 1.500.000/bulan');

      final kos2 = Kos.fromJson({...sampleJson, 'price_per_month': 750000});
      expect(kos2.formattedPrice, 'Rp 750.000');

      final kos3 = Kos.fromJson({...sampleJson, 'price_per_month': 500});
      expect(kos3.formattedPrice, 'Rp 500');

      final kosZero = Kos.fromJson({...sampleJson, 'price_per_month': 0});
      expect(kosZero.formattedPrice, 'Rp 0');
    });

    test('genderLabel returns capitalized Indonesian label', () {
      expect(
        Kos.fromJson({...sampleJson, 'gender_type': 'putra'}).genderLabel,
        'Putra',
      );
      expect(
        Kos.fromJson({...sampleJson, 'gender_type': 'PUTRI'}).genderLabel,
        'Putri',
      );
      expect(
        Kos.fromJson({...sampleJson, 'gender_type': 'campur'}).genderLabel,
        'Campur',
      );
      expect(
        Kos.fromJson({...sampleJson, 'gender_type': ''}).genderLabel,
        'Campur',
      );
    });

    test('activeFacilities returns only enabled facilities in order', () {
      final kos = Kos.fromJson(sampleJson);
      expect(kos.activeFacilities, ['WiFi', 'AC', 'Listrik Termasuk']);

      final kosNoFacilities = Kos.fromJson({
        ...sampleJson,
        'has_wifi': false,
        'has_ac': false,
        'has_private_bathroom': false,
        'includes_electricity': false,
      });
      expect(kosNoFacilities.activeFacilities, isEmpty);
    });

    test('copyWith updates specified fields and preserves others', () {
      final original = Kos.fromJson(sampleJson);
      final updated = original.copyWith(
        name: 'Kos Baru',
        pricePerMonth: 2000000,
        hasPrivateBathroom: true,
      );

      expect(updated.id, original.id);
      expect(updated.ownerId, original.ownerId);
      expect(updated.name, 'Kos Baru');
      expect(updated.pricePerMonth, 2000000);
      expect(updated.hasPrivateBathroom, isTrue);
      expect(updated.hasWifi, original.hasWifi);
    });
  });
}

