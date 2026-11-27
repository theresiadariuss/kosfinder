import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class _FakeKosRepository implements KosRepository {
  @override
  Future<List<Kos>> fetchAll() async => const [];

  @override
  Future<Kos?> fetchById(String id) async => null;
}

void main() {
  testWidgets('KosFinderApp renders KosListScreen as home without Supabase',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      KosFinderApp(kosRepository: _FakeKosRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('KosFinder'), findsOneWidget);
    expect(find.text('Belum ada kos yang terdaftar'), findsOneWidget);
  });
}
