import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_list_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';
import 'package:kosfinder/widgets/filter_bottom_sheet.dart';
import 'package:provider/provider.dart';

class _FakeKosRepository implements KosRepository {
  _FakeKosRepository({
    this.items = const [],
    this.shouldThrow = false,
    this.completer,
  });

  List<Kos> items;
  bool shouldThrow;
  Completer<List<Kos>>? completer;
  int fetchAllCalls = 0;

  @override
  Future<List<Kos>> fetchAll() async {
    fetchAllCalls++;
    if (completer != null) {
      return completer!.future;
    }
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return items;
  }

  @override
  Future<Kos?> fetchById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

Kos _sampleKos({
  String id = '1',
  String name = 'Kos Melati',
  String area = 'Singaraja',
  int pricePerMonth = 900000,
  String genderType = 'putri',
  bool hasWifi = true,
  bool hasAc = false,
  bool hasPrivateBathroom = true,
  bool includesElectricity = false,
}) {
  return Kos(
    id: id,
    ownerId: 'owner-1',
    name: name,
    area: area,
    address: 'Jl. Ahmad Yani No. 1',
    description: 'Kos nyaman dekat kampus',
    pricePerMonth: pricePerMonth,
    genderType: genderType,
    hasWifi: hasWifi,
    hasAc: hasAc,
    hasPrivateBathroom: hasPrivateBathroom,
    includesElectricity: includesElectricity,
    whatsappNumber: '081234567890',
  );
}

Widget _buildTestApp(KosRepository repository) {
  return ChangeNotifierProvider(
    create: (_) => KosListProvider(repository: repository),
    child: const MaterialApp(
      home: KosListScreen(),
    ),
  );
}

void main() {
  group('KosListScreen Widget Tests', () {
    testWidgets('shows loading indicator while fetching data', (tester) async {
      final completer = Completer<List<Kos>>();
      final repo = _FakeKosRepository(completer: completer);

      await tester.pumpWidget(_buildTestApp(repo));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty message when no kos data is available (US01-AC2)',
        (tester) async {
      final repo = _FakeKosRepository(items: []);

      await tester.pumpWidget(_buildTestApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada kos yang terdaftar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows friendly error message and retries on button tap (US01-AC3)',
        (tester) async {
      final repo = _FakeKosRepository(shouldThrow: true);

      await tester.pumpWidget(_buildTestApp(repo));
      await tester.pumpAndSettle();

      expect(
        find.text('Gagal memuat data, periksa koneksi internet Anda'),
        findsOneWidget,
      );
      expect(find.text('Coba Lagi'), findsOneWidget);

      repo.shouldThrow = false;
      repo.items = [_sampleKos()];

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(repo.fetchAllCalls, 2);
      expect(find.text('Kos Melati'), findsOneWidget);
      expect(find.text('Gagal memuat data, periksa koneksi internet Anda'), findsNothing);
    });

    testWidgets('displays kos cards with formatted price, gender, and facilities (US01-AC1, US01-AC4)',
        (tester) async {
      final repo = _FakeKosRepository(
        items: [
          _sampleKos(
            id: '1',
            name: 'Kos Melati',
            area: 'Singaraja',
            pricePerMonth: 900000,
            genderType: 'putri',
            hasWifi: true,
            hasAc: true,
            hasPrivateBathroom: true,
            includesElectricity: true,
          ),
        ],
      );

      await tester.pumpWidget(_buildTestApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Kos Melati'), findsOneWidget);
      expect(find.text('Singaraja'), findsOneWidget);
      expect(find.text('Rp 900.000/bulan'), findsOneWidget);
      expect(find.text('Putri'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(find.byIcon(Icons.bathtub_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('search bar filters kos case-insensitively (US03-AC1)',
        (tester) async {
      final repo = _FakeKosRepository(
        items: [
          _sampleKos(id: '1', name: 'Kos Melati', area: 'Singaraja'),
          _sampleKos(id: '2', name: 'Kos Kenanga', area: 'Denpasar'),
        ],
      );

      await tester.pumpWidget(_buildTestApp(repo));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('search_kos_field')),
        'singaraja',
      );
      await tester.pumpAndSettle();

      expect(find.text('Kos Melati'), findsOneWidget);
      expect(find.text('Kos Kenanga'), findsNothing);
    });

    testWidgets(
        'filter bottom sheet filters by max price and facilities (US03-AC2, US03-AC3)',
        (tester) async {
      final repo = _FakeKosRepository(
        items: [
          _sampleKos(
            id: '1',
            name: 'Kos Hemat',
            pricePerMonth: 1200000,
            hasWifi: true,
            hasAc: true,
          ),
          _sampleKos(
            id: '2',
            name: 'Kos Mahal',
            pricePerMonth: 2000000,
            hasWifi: true,
            hasAc: true,
          ),
          _sampleKos(
            id: '3',
            name: 'Kos Tanpa AC',
            pricePerMonth: 900000,
            hasWifi: true,
            hasAc: false,
          ),
        ],
      );

      await tester.pumpWidget(_buildTestApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('max_price_field')),
        '1500000',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(FilterBottomSheet),
          matching: find.text('WiFi'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(FilterBottomSheet),
          matching: find.text('AC'),
        ),
      );
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(find.text('Kos Hemat'), findsOneWidget);
      expect(find.text('Kos Mahal'), findsNothing);
      expect(find.text('Kos Tanpa AC'), findsNothing);
    });

    testWidgets('shows empty filter message when no kos matches (US03-AC4)',
        (tester) async {
      final repo = _FakeKosRepository(
        items: [_sampleKos(id: '1', name: 'Kos Melati', area: 'Singaraja')],
      );

      await tester.pumpWidget(_buildTestApp(repo));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('search_kos_field')),
        'jakarta',
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Tidak ada kos yang sesuai dengan kriteria pencarian'),
        findsOneWidget,
      );
    });
  });
}

