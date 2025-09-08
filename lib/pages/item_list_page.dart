import 'package:flutter/material.dart';
import '../data/tourisme_repository.dart';
import '../models/tourisme_item.dart';
import 'detail_page.dart';

class ItemListPage extends StatefulWidget {
  final String? category;
  final String? query;
  const ItemListPage({super.key, this.category, this.query});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final repo = TourismeRepository();
  late TextEditingController _controller;
  List<TourismeItem> _items = [];
  bool _loading = true;

  // Senegal's 14 regions
  final List<String> regions = const [
    'Dakar', 'Thiès', 'Diourbel', 'Saint-Louis', 'Kaolack', 'Fatick', 'Louga',
    'Kaffrine', 'Tambacounda', 'Kédougou', 'Kolda', 'Sédhiou', 'Ziguinchor', 'Matam'
  ];

  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query ?? '');
    _search();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    final items = await repo.search(query: _controller.text, category: widget.category);
    setState(() {
      if (_selectedRegion != null && _selectedRegion!.isNotEmpty) {
        _items = items.where((it) {
          final city = (it.city ?? it.address ?? '').toLowerCase();
          return city.contains(_selectedRegion!.toLowerCase());
        }).toList();
      } else {
        _items = items;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category ?? 'Résultats'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Filtrer...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
            /*     const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    hint: const Text('Région'),
                    value: _selectedRegion,
                    onChanged: (val) {
                      setState(() => _selectedRegion = val);
                      _search();
                    },
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Toutes')),
                      ...regions.map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    ],
                  ),
                ), */
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.tune),
                  label: const Text('Filtrer'),
                )
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _items.isEmpty && !_loading
                ? const Center(child: Text('Aucun résultat'))
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final it = _items[index];
                      return ListTile(
                        title: Text(it.name),
                        subtitle: Text([
                          if (it.city != null) it.city!,
                          if (it.address != null) it.address!,
                          if (it.phone != null) '☎ ${it.phone!}',
                        ].where((e) => e.isNotEmpty).join(' · ')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailPage(item: it),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}