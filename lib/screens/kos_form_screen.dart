import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/kos.dart';
import '../providers/owner_kos_provider.dart';

/// Form screen for adding a new kos (US05) or editing an existing kos (US06).
class KosFormScreen extends StatefulWidget {
  const KosFormScreen({
    super.key,
    required this.ownerId,
    this.initialKos,
  });

  final String ownerId;
  final Kos? initialKos;

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _whatsappController;

  late String _genderType;
  late bool _hasWifi;
  late bool _hasAc;
  late bool _hasPrivateBathroom;
  late bool _includesElectricity;

  bool get _isEditMode => widget.initialKos != null;

  @override
  void initState() {
    super.initState();
    final kos = widget.initialKos;
    _nameController = TextEditingController(text: kos?.name ?? '');
    _areaController = TextEditingController(text: kos?.area ?? '');
    _addressController = TextEditingController(text: kos?.address ?? '');
    _descriptionController =
        TextEditingController(text: kos?.description ?? '');
    _priceController = TextEditingController(
      text: kos != null ? kos.pricePerMonth.toString() : '',
    );
    _whatsappController =
        TextEditingController(text: kos?.whatsappNumber ?? '');
    _genderType = kos?.genderType ?? 'campur';
    _hasWifi = kos?.hasWifi ?? false;
    _hasAc = kos?.hasAc ?? false;
    _hasPrivateBathroom = kos?.hasPrivateBathroom ?? false;
    _includesElectricity = kos?.includesElectricity ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'owner_id': widget.ownerId,
      'name': _nameController.text.trim(),
      'area': _areaController.text.trim(),
      'address': _addressController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price_per_month': int.parse(_priceController.text.trim()),
      'gender_type': _genderType,
      'has_wifi': _hasWifi,
      'has_ac': _hasAc,
      'has_private_bathroom': _hasPrivateBathroom,
      'includes_electricity': _includesElectricity,
      'whatsapp_number': _whatsappController.text.trim(),
    };

    final provider = context.read<OwnerKosProvider>();
    final bool ok;
    if (_isEditMode) {
      ok = await provider.updateKos(widget.initialKos!.id, data);
    } else {
      ok = await provider.addKos(data);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Gagal menyimpan data. Silakan coba lagi.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerKosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Kos' : 'Tambah Kos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('kos_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kos',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama kos wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('kos_area_field'),
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / Lokasi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Area wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('kos_address_field'),
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('kos_description_field'),
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('kos_price_field'),
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Harga per Bulan (Rp)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                  final price = int.tryParse(v.trim());
                  if (price == null || price <= 0) return 'Harga harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('kos_gender_dropdown'),
                initialValue: _genderType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Penghuni',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'putra', child: Text('Putra')),
                  DropdownMenuItem(value: 'putri', child: Text('Putri')),
                  DropdownMenuItem(value: 'campur', child: Text('Campur')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _genderType = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('kos_whatsapp_field'),
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nomor WhatsApp wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Fasilitas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              CheckboxListTile(
                key: const Key('kos_wifi_checkbox'),
                title: const Text('WiFi'),
                value: _hasWifi,
                onChanged: (v) => setState(() => _hasWifi = v ?? false),
              ),
              CheckboxListTile(
                key: const Key('kos_ac_checkbox'),
                title: const Text('AC'),
                value: _hasAc,
                onChanged: (v) => setState(() => _hasAc = v ?? false),
              ),
              CheckboxListTile(
                key: const Key('kos_bathroom_checkbox'),
                title: const Text('Kamar Mandi Dalam'),
                value: _hasPrivateBathroom,
                onChanged: (v) =>
                    setState(() => _hasPrivateBathroom = v ?? false),
              ),
              CheckboxListTile(
                key: const Key('kos_electricity_checkbox'),
                title: const Text('Listrik Termasuk'),
                value: _includesElectricity,
                onChanged: (v) =>
                    setState(() => _includesElectricity = v ?? false),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('kos_form_submit_button'),
                onPressed: provider.isLoading ? null : _submit,
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Simpan Perubahan' : 'Tambah Kos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
