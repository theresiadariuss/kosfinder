import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_form_screen.dart';

Widget _wrap(Widget child, KosRepository repo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => OwnerKosProvider(repository: repo)),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('KosFormScreen Tests (US05-AC1)', () {
    testWidgets('US05-AC1: Validasi nama kos wajib diisi', (tester) async {
      final repo = KosRepository();
      await tester.pumpWidget(_wrap(const KosFormScreen(ownerId: 'uid-1'), repo));

      final button = find.byKey(const Key('kos_form_submit_button'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Nama kos wajib diisi'), findsOneWidget);
    });

    testWidgets('US05-AC1: Validasi area wajib diisi', (tester) async {
      final repo = KosRepository();
      await tester.pumpWidget(_wrap(const KosFormScreen(ownerId: 'uid-1'), repo));

      await tester.enterText(find.byKey(const Key('kos_name_field')), 'Kos Test');
      final button = find.byKey(const Key('kos_form_submit_button'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Area wajib diisi'), findsOneWidget);
    });

    testWidgets('US05-AC1: Validasi harga harus angka lebih dari 0', (tester) async {
      final repo = KosRepository();
      await tester.pumpWidget(_wrap(const KosFormScreen(ownerId: 'uid-1'), repo));

      await tester.enterText(find.byKey(const Key('kos_name_field')), 'Kos Test');
      await tester.enterText(find.byKey(const Key('kos_area_field')), 'Singaraja');
      await tester.enterText(find.byKey(const Key('kos_address_field')), 'Jl. Test No. 1');
      await tester.enterText(find.byKey(const Key('kos_price_field')), '0');
      await tester.enterText(find.byKey(const Key('kos_whatsapp_field')), '08123456789');
      final button = find.byKey(const Key('kos_form_submit_button'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Harga harus lebih dari 0'), findsOneWidget);
    });

    testWidgets('US05-AC1: Validasi nomor WhatsApp wajib diisi', (tester) async {
      final repo = KosRepository();
      await tester.pumpWidget(_wrap(const KosFormScreen(ownerId: 'uid-1'), repo));

      await tester.enterText(find.byKey(const Key('kos_name_field')), 'Kos Test');
      await tester.enterText(find.byKey(const Key('kos_area_field')), 'Singaraja');
      await tester.enterText(find.byKey(const Key('kos_address_field')), 'Jl. Test No. 1');
      await tester.enterText(find.byKey(const Key('kos_price_field')), '1000000');
      final button = find.byKey(const Key('kos_form_submit_button'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Nomor WhatsApp wajib diisi'), findsOneWidget);
    });

    testWidgets('US05-AC1: Tambah kos berhasil mengirim data ke repository', (tester) async {
      final repo = KosRepository();
      Map<String, dynamic>? savedData;
      repo.setCrudHandlers(
        insert: (data) async => savedData = data,
      );

      await tester.pumpWidget(_wrap(const KosFormScreen(ownerId: 'uid-1'), repo));

      await tester.enterText(find.byKey(const Key('kos_name_field')), 'Kos Mawar Indah');
      await tester.enterText(find.byKey(const Key('kos_area_field')), 'Banyuasri');
      await tester.enterText(find.byKey(const Key('kos_address_field')), 'Jl. Serma Karma');
      await tester.enterText(find.byKey(const Key('kos_price_field')), '1500000');
      await tester.enterText(find.byKey(const Key('kos_whatsapp_field')), '081999888777');

      // Toggle wifi
      final wifi = find.byKey(const Key('kos_wifi_checkbox'));
      await tester.ensureVisible(wifi);
      await tester.tap(wifi);
      await tester.pump();

      // Submit
      final button = find.byKey(const Key('kos_form_submit_button'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(savedData, isNotNull);
      expect(savedData!['name'], 'Kos Mawar Indah');
      expect(savedData!['area'], 'Banyuasri');
      expect(savedData!['price_per_month'], 1500000);
      expect(savedData!['whatsapp_number'], '081999888777');
      expect(savedData!['has_wifi'], isTrue);
      expect(savedData!['owner_id'], 'uid-1');
    });
  });
}
