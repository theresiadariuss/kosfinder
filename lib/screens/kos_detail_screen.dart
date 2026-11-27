import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/kos.dart';

/// Detail screen showing full information for a single boarding house (`US02`).
class KosDetailScreen extends StatelessWidget {
  const KosDetailScreen({super.key, required this.kos});

  final Kos kos;

  static const String snackBarMessage = 'Nomor WhatsApp berhasil disalin';

  void _copyWhatsApp(BuildContext context) {
    Clipboard.setData(ClipboardData(text: kos.whatsappNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(snackBarMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(kos.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nama, area, tipe penghuni
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    kos.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    kos.genderLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Area
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  kos.area,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Alamat lengkap
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    kos.address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Harga
            Text(
              kos.formattedPricePerMonth,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 12),

            // Deskripsi
            Text(
              'Deskripsi',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kos.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Fasilitas
            Text(
              'Fasilitas',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _FacilityRow(
              icon: Icons.wifi,
              label: 'WiFi',
              active: kos.hasWifi,
            ),
            _FacilityRow(
              icon: Icons.ac_unit,
              label: 'AC',
              active: kos.hasAc,
            ),
            _FacilityRow(
              icon: Icons.bathtub_outlined,
              label: 'Kamar Mandi Dalam',
              active: kos.hasPrivateBathroom,
            ),
            _FacilityRow(
              icon: Icons.bolt,
              label: 'Listrik Termasuk',
              active: kos.includesElectricity,
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 12),

            // Kontak WhatsApp
            Text(
              'Kontak Pemilik',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _copyWhatsApp(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        kos.whatsappNumber,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk untuk menyalin nomor WhatsApp',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FacilityRow extends StatelessWidget {
  const _FacilityRow({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        active ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: active
                      ? null
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  decoration:
                      active ? null : TextDecoration.lineThrough,
                ),
          ),
        ],
      ),
    );
  }
}

