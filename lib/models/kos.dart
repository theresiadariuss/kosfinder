/// Data model representing a boarding house (kos) from the Supabase `kos` table.
class Kos {
  const Kos({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.area,
    required this.address,
    required this.description,
    required this.pricePerMonth,
    required this.genderType,
    this.hasWifi = false,
    this.hasAc = false,
    this.hasPrivateBathroom = false,
    this.includesElectricity = false,
    required this.whatsappNumber,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String area;
  final String address;
  final String description;
  final int pricePerMonth;
  final String genderType;
  final bool hasWifi;
  final bool hasAc;
  final bool hasPrivateBathroom;
  final bool includesElectricity;
  final String whatsappNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Creates a [Kos] instance from a Supabase PostgreSQL JSON map.
  factory Kos.fromJson(Map<String, dynamic> json) {
    return Kos(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      area: json['area'] as String? ?? '',
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pricePerMonth: (json['price_per_month'] as num?)?.toInt() ?? 0,
      genderType: json['gender_type'] as String? ?? 'campur',
      hasWifi: json['has_wifi'] as bool? ?? false,
      hasAc: json['has_ac'] as bool? ?? false,
      hasPrivateBathroom: json['has_private_bathroom'] as bool? ?? false,
      includesElectricity: json['includes_electricity'] as bool? ?? false,
      whatsappNumber: json['whatsapp_number'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Converts this [Kos] instance into a snake_case JSON map for Supabase.
  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId && id.isNotEmpty) 'id': id,
      'owner_id': ownerId,
      'name': name,
      'area': area,
      'address': address,
      'description': description,
      'price_per_month': pricePerMonth,
      'gender_type': genderType,
      'has_wifi': hasWifi,
      'has_ac': hasAc,
      'has_private_bathroom': hasPrivateBathroom,
      'includes_electricity': includesElectricity,
      'whatsapp_number': whatsappNumber,
    };
  }

  /// Returns a copy of this [Kos] with the specified fields replaced.
  Kos copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? area,
    String? address,
    String? description,
    int? pricePerMonth,
    String? genderType,
    bool? hasWifi,
    bool? hasAc,
    bool? hasPrivateBathroom,
    bool? includesElectricity,
    String? whatsappNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Kos(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      area: area ?? this.area,
      address: address ?? this.address,
      description: description ?? this.description,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      genderType: genderType ?? this.genderType,
      hasWifi: hasWifi ?? this.hasWifi,
      hasAc: hasAc ?? this.hasAc,
      hasPrivateBathroom: hasPrivateBathroom ?? this.hasPrivateBathroom,
      includesElectricity: includesElectricity ?? this.includesElectricity,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formats [pricePerMonth] as Rupiah with dot thousand separators, e.g. `Rp 1.500.000`.
  String get formattedPrice {
    final isNegative = pricePerMonth < 0;
    final digits = pricePerMonth.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      if (i > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return isNegative ? '-Rp ${buffer.toString()}' : 'Rp ${buffer.toString()}';
  }

  /// Formats [pricePerMonth] with monthly suffix, e.g. `Rp 1.500.000/bulan`.
  String get formattedPricePerMonth => '$formattedPrice/bulan';

  /// Human-readable label for [genderType].
  String get genderLabel {
    switch (genderType.toLowerCase()) {
      case 'putra':
        return 'Putra';
      case 'putri':
        return 'Putri';
      case 'campur':
        return 'Campur';
      default:
        if (genderType.isEmpty) return 'Campur';
        return genderType[0].toUpperCase() + genderType.substring(1);
    }
  }

  /// List of active facility names for display.
  List<String> get activeFacilities => [
        if (hasWifi) 'WiFi',
        if (hasAc) 'AC',
        if (hasPrivateBathroom) 'Kamar Mandi Dalam',
        if (includesElectricity) 'Listrik Termasuk',
      ];
}

