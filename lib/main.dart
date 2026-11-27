import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'providers/kos_list_provider.dart';
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
  });

  final KosRepository? kosRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => KosListProvider(
            repository: kosRepository ?? KosRepository(),
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
