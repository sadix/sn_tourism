import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/tourisme_item.dart';

class TourismeRepository {
  static final TourismeRepository _instance = TourismeRepository._internal();
  factory TourismeRepository() => _instance;
  TourismeRepository._internal();

  List<TourismeItem>? _cache;

  Future<List<TourismeItem>> loadItems() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/tourisme.json');
    final data = json.decode(raw);
    if (data[0] is List) {
      _cache = data['output'].map((e) => TourismeItem.fromJson(e as Map<String, dynamic>)).toList();
    } else if (data[0] is Map && data[0]['output'] is List) {
      _cache = (data[0]['output'] as List)
          .map((e) => TourismeItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _cache = [];
    }
    return _cache!;
  }

  Future<List<String>> getCategories() async {
    final items = await loadItems();
    final set = <String>{};
    for (final it in items) {
      if (it.category != null && it.category!.trim().isNotEmpty) {
        set.add(it.category!.trim());
      }
    }
    final list = set.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  Future<List<TourismeItem>> search({
    String? query,
    String? category,
  }) async {
    final items = await loadItems();
    final q = (query ?? '').trim().toLowerCase();
    return items.where((it) {
      final matchCategory = category == null || (it.category ?? '').toLowerCase() == category.toLowerCase();
      final hay = [
        it.name,
        it.category ?? '',
        it.address ?? '',
        it.city ?? '',
        it.phone ?? '',
        it.email ?? '',
        it.website ?? '',
        ...it.services
      ].join(' ').toLowerCase();
      final matchQuery = q.isEmpty || hay.contains(q);
      return matchCategory && matchQuery;
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}