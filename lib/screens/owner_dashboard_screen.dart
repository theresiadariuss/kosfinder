import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Owner dashboard screen skeleton with logout functionality (US04-AC2, US04-AC4).
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().signOut();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pemilik'),
        actions: [
          IconButton(
            key: const Key('logout_button'),
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dashboard_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Selamat Datang, ${user?.email ?? "Pemilik"}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelola kos Anda melalui dashboard ini.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
