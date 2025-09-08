import 'dart:convert';

class TourismeItem {
  final String id; // generated if not provided
  final String name;
  final String? category; // e.g., Agence de voyages, Location de voitures
  final String? address;
  final String? city;
  final String? phone;
  final String? email;
  final String? website;
  final List<String> services; // e.g., billeterie, excursions, etc.

  TourismeItem({
    required this.id,
    required this.name,
    this.category,
    this.address,
    this.city,
    this.phone,
    this.email,
    this.website,
    this.services = const [],
  });

  factory TourismeItem.fromJson(Map<String, dynamic> json) {
    // Try to be resilient to varying key names / cases
    String readStr(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null && json[k].toString().trim().isNotEmpty) {
          return json[k].toString();
        }
      }
      return '';
    }

    List<String> readServices() {
      final raw = json['services'] ?? json['prestations'] ?? json['options'];
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
      if (raw is String) {
        return raw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    String id = readStr(['id']);
    if (id.isEmpty) {
      // derive a stable-ish id from name+phone+email
      final seed = readStr(['name', 'nom', 'designation','title']) +
          readStr(['phone', 'tel', 'telephone']) +
          readStr(['email', 'mail']);
      id = base64Url.encode(utf8.encode(seed)).substring(0,12);
    }

    return TourismeItem(
      id: id,
      name: readStr(['name', 'nom', 'designation','title']),
      category: readStr(['category', 'categorie', 'type']).ifEmptyOrNull,
      address: readStr(['address', 'adresse', 'location']).ifEmptyOrNull,
      city: readStr(['city', 'ville']).ifEmptyOrNull,
      phone: readStr(['phone', 'tel', 'telephone']).ifEmptyOrNull,
      email: readStr(['email', 'mail']).ifEmptyOrNull,
      website: readStr(['website', 'site', 'url']).ifEmptyOrNull,
      services: readServices(),
    );
  }
}

extension on String {
  String? get ifEmptyOrNull => trim().isEmpty ? null : this;
}