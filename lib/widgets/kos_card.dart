import 'package:flutter/material.dart';

import '../models/kos.dart';
import '../screens/kos_detail_screen.dart';

/// Card widget displaying summary information for a public boarding house (`US01-AC1`).
/// Tapping the card navigates to [KosDetailScreen] (`US02-AC1`).
class KosCard extends StatelessWidget {
  const KosCard({
    super.key,
    required this.kos,
  });

  final Kos kos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => KosDetailScreen(kos: kos),
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    kos.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kos.genderLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    kos.area,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              kos.formattedPricePerMonth,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (kos.hasWifi ||
                kos.hasAc ||
                kos.hasPrivateBathroom ||
                kos.includesElectricity) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  if (kos.hasWifi)
                    const _FacilityIcon(
                      icon: Icons.wifi,
                      label: 'WiFi',
                    ),
                  if (kos.hasAc)
                    const _FacilityIcon(
                      icon: Icons.ac_unit,
                      label: 'AC',
                    ),
                  if (kos.hasPrivateBathroom)
                    const _FacilityIcon(
                      icon: Icons.bathtub_outlined,
                      label: 'KM Dalam',
                    ),
                  if (kos.includesElectricity)
                    const _FacilityIcon(
                      icon: Icons.bolt,
                      label: 'Listrik',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

class _FacilityIcon extends StatelessWidget {
  const _FacilityIcon({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Tooltip(
      message: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

