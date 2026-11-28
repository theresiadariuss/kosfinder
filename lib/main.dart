import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/kos_list_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/kos_repository.dart';
import 'screens/kos_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  runApp(const KosFinderApp());
}

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({
    super.key,
    this.kosRepository,
    this.authRepository,
  });

  final KosRepository? kosRepository;
  final AuthRepository? authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => KosListProvider(
            repository: kosRepository ?? KosRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: authRepository ?? SupabaseAuthRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'KosFinder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const KosListScreen(),
      ),
    );
  }
}
