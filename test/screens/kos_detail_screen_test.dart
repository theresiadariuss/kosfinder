import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_list_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';
import 'package:provider/provider.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeKosRepository implements KosRepository {
  _FakeKosRepository({this.items = const []});

  final List<Kos> items;

  @override
  Future<List<Kos>> fetchAll() async => items;

  @override
  Future<Kos?> fetchById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

Kos _sampleKos() => const Kos(
      id: 'kos-1',
      ownerId: 'owner-1',
      name: 'Kos Melati Indah',
      area: 'Singaraja',
      address: 'Jl. Ahmad Yani No. 1, Singaraja, Bali',
      description: 'Kos nyaman dekat kampus dengan fasilitas lengkap.',
      pricePerMonth: 900000,
      genderType: 'putri',
      hasWifi: true,
      hasAc: true,
      hasPrivateBathroom: true,
      includesElectricity: false,
      whatsappNumber: '081234567890',
    );

// ---------------------------------------------------------------------------
// Helper builders
// ---------------------------------------------------------------------------

Widget _buildDetailApp(Kos kos) {
  return MaterialApp(
    home: KosDetailScreen(kos: kos),
  );
}

Widget _buildListApp(List<Kos> items) {
  return ChangeNotifierProvider(
    create: (_) => KosListProvider(repository: _FakeKosRepository(items: items)),
    child: const MaterialApp(
      home: KosListScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('KosDetailScreen', () {
    testWidgets('displays all kos fields (US02-AC1)', (tester) async {
      final kos = _sampleKos();
      await tester.pumpWidget(_buildDetailApp(kos));

      // name appears in AppBar and body header
      expect(find.text('Kos Melati Indah'), findsWidgets);
      expect(find.text('Singaraja'), findsOneWidget);
      expect(find.text('Jl. Ahmad Yani No. 1, Singaraja, Bali'), findsOneWidget);
      expect(find.text('Kos nyaman dekat kampus dengan fasilitas lengkap.'), findsOneWidget);
      expect(find.text('Rp 900.000/bulan'), findsOneWidget);
      expect(find.text('Putri'), findsOneWidget);
      expect(find.text('081234567890'), findsOneWidget);
    });

    testWidgets('shows all facility rows (US02-AC1)', (tester) async {
      final kos = _sampleKos();
      await tester.pumpWidget(_buildDetailApp(kos));

      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.text('Kamar Mandi Dalam'), findsOneWidget);
      expect(find.text('Listrik Termasuk'), findsOneWidget);
    });

    testWidgets('tapping WhatsApp row copies number and shows SnackBar (US02-AC2)',
        (tester) async {
      String? copiedText;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );

      final kos = _sampleKos();
      await tester.pumpWidget(_buildDetailApp(kos));

      await tester.tap(find.text('081234567890'));
      await tester.pump();

      expect(copiedText, '081234567890');
      expect(find.text(KosDetailScreen.snackBarMessage), findsOneWidget);

      // Cleanup
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
  });

  group('KosCard navigation to KosDetailScreen', () {
    testWidgets('tapping a kos card navigates to KosDetailScreen (US02-AC1)',
        (tester) async {
      final items = [_sampleKos()];
      await tester.pumpWidget(_buildListApp(items));
      await tester.pumpAndSettle();

      // Card is visible
      expect(find.text('Kos Melati Indah'), findsOneWidget);

      // Tap the card
      await tester.tap(find.text('Kos Melati Indah'));
      await tester.pumpAndSettle();

      // Now on detail screen: address is visible (not shown on list)
      expect(
        find.text('Jl. Ahmad Yani No. 1, Singaraja, Bali'),
        findsOneWidget,
      );
      expect(find.byType(KosDetailScreen), findsOneWidget);
    });
  });
}

