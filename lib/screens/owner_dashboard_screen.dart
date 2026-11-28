import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kos.dart';
import '../providers/auth_provider.dart';
import '../providers/owner_kos_provider.dart';
import 'kos_form_screen.dart';

/// Owner dashboard screen displaying the owner's kos list and management actions (US04, US05).
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = Provider.of<AuthProvider?>(context, listen: false)?.currentUser;
      final ownerProvider = Provider.of<OwnerKosProvider?>(context, listen: false);
      if (user != null && ownerProvider != null) {
        ownerProvider.loadOwnerKos(user.id);
      }
    });
  }

  Future<void> _logout() async {
    final auth = Provider.of<AuthProvider?>(context, listen: false);
    if (auth != null) {
      await auth.signOut();
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _openAddKos(String? userId) async {
    if (userId == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => KosFormScreen(ownerId: userId),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      final ownerProvider = Provider.of<OwnerKosProvider?>(context, listen: false);
      ownerProvider?.loadOwnerKos(userId);
    }
  }

  Future<void> _openEditKos(String? userId, Kos kos) async {
    if (userId == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => KosFormScreen(ownerId: userId, initialKos: kos),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      final ownerProvider = Provider.of<OwnerKosProvider?>(context, listen: false);
      ownerProvider?.loadOwnerKos(userId);
    }
  }

  Future<void> _confirmDelete(Kos kos) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kos'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kos ini secara permanen?',
        ),
        actions: [
          TextButton(
            key: const Key('cancel_delete_button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('confirm_delete_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ownerProvider =
          Provider.of<OwnerKosProvider?>(context, listen: false);
      final ok = await ownerProvider?.deleteKos(kos.id) ?? false;
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ownerProvider?.errorMessage ?? 'Gagal menghapus kos.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider?>(context);
    final ownerProvider = Provider.of<OwnerKosProvider?>(context);
    final user = authProvider?.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pemilik'),
        actions: [
          IconButton(
            key: const Key('logout_button'),
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(context, ownerProvider, user?.id, user?.email),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_kos_fab'),
        tooltip: 'Tambah Kos',
        onPressed: () => _openAddKos(user?.id),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OwnerKosProvider? provider,
    String? userId,
    String? email,
  ) {
    if (provider != null && provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider != null && provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final user = Provider.of<AuthProvider?>(context, listen: false)?.currentUser;
                  if (user != null) {
                    provider.loadOwnerKos(user.id);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider == null || provider.ownerKosList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_work_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Selamat Datang, ${email ?? "Pemilik"}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Belum ada kos yang Anda daftarkan.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.ownerKosList.length,
      itemBuilder: (context, index) {
        final kos = provider.ownerKosList[index];
        return Card(
          key: Key('owner_kos_card_${kos.id}'),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(
              kos.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${kos.area} · ${kos.formattedPricePerMonth}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: Key('edit_kos_${kos.id}'),
                  tooltip: 'Ubah Kos',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _openEditKos(userId, kos),
                ),
                IconButton(
                  key: Key('delete_kos_${kos.id}'),
                  tooltip: 'Hapus Kos',
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _confirmDelete(kos),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
