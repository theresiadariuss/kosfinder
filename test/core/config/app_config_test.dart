import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('default configuration values should be strings', () {
      expect(AppConfig.supabaseUrl, isA<String>());
      expect(AppConfig.supabaseAnonKey, isA<String>());
    });

    test('isConfigured returns false when URL or anonKey are empty', () {
      // In normal test runs without --dart-define, these default to empty
      if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
        expect(AppConfig.isConfigured, isFalse);
      }
    });
  });
}
