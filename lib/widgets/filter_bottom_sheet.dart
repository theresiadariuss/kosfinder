import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/kos_list_provider.dart';

/// Interactive bottom sheet for filtering boarding houses by max price and facilities (`US03-AC2`, `US03-AC3`).
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late final TextEditingController _maxPriceController;
  late bool _wifi;
  late bool _ac;
  late bool _privateBathroom;
  late bool _includesElectricity;

  @override
  void initState() {
    super.initState();
    final provider = context.read<KosListProvider>();
    _maxPriceController = TextEditingController(
      text: provider.maxPrice?.toString() ?? '',
    );
    _wifi = provider.filterWifi;
    _ac = provider.filterAc;
    _privateBathroom = provider.filterPrivateBathroom;
    _includesElectricity = provider.filterIncludesElectricity;
  }

  @override
  void dispose() {
    _maxPriceController.dispose();
    super.dispose();
  }

  void _apply() {
    final rawPrice = _maxPriceController.text.trim();
    final maxPrice = rawPrice.isEmpty ? null : int.tryParse(rawPrice);

    context.read<KosListProvider>().applyFilters(
          maxPrice: maxPrice,
          wifi: _wifi,
          ac: _ac,
          privateBathroom: _privateBathroom,
          includesElectricity: _includesElectricity,
        );
    Navigator.of(context).pop();
  }

  void _reset() {
    context.read<KosListProvider>().resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Kos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('max_price_field'),
              controller: _maxPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Harga Maksimal (Rp/bulan)',
                hintText: 'Contoh: 1500000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Fasilitas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('WiFi'),
              value: _wifi,
              onChanged: (value) => setState(() => _wifi = value ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('AC'),
              value: _ac,
              onChanged: (value) => setState(() => _ac = value ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Kamar Mandi Dalam'),
              value: _privateBathroom,
              onChanged: (value) =>
                  setState(() => _privateBathroom = value ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Listrik Termasuk'),
              value: _includesElectricity,
              onChanged: (value) =>
                  setState(() => _includesElectricity = value ?? false),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
