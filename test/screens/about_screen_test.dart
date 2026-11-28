import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/screens/about_screen.dart';

void main() {
  testWidgets('AboutScreen displays app name and developer NIM - Name',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutScreen(),
      ),
    );

    expect(find.text('KosFinder'), findsOneWidget);
    expect(find.text('2415051116 - Theresia Darius'), findsOneWidget);
  });
}
