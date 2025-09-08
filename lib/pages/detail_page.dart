import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tourisme_item.dart';

class DetailPage extends StatelessWidget {
  final TourismeItem item;
  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (item.category != null)
            Text(
              item.category!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 8),
          if (item.address != null || item.city != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text([
                    if (item.address != null) item.address!,
                    if (item.city != null) item.city!,
                  ].join(', ')),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (item.phone != null)
                _ActionChip(
                  icon: Icons.call,
                  label: 'Appeler',
                  onTap: () => _tryLaunch(Uri.parse('tel:${item.phone}')),
                ),
              if (item.email != null)
                _ActionChip(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  onTap: () => _tryLaunch(Uri.parse('mailto:${item.email}')),
                ),
              if (item.website != null)
                _ActionChip(
                  icon: Icons.public,
                  label: 'Site web',
                  onTap: () => _tryLaunch(Uri.parse(_normalizeUrl(item.website!))),
                ),
              if (item.address != null || item.city != null)
                _ActionChip(
                  icon: Icons.map_outlined,
                  label: 'Itinéraire',
                  onTap: () {
                    final q = Uri.encodeComponent([
                      if (item.address != null) item.address!,
                      if (item.city != null) item.city!,
                    ].join(', '));
                    _tryLaunch(Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (item.services.isNotEmpty) ...[
            Text('Services', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.services
                  .map((s) => Chip(
                        label: Text(s),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  static Future<void> _tryLaunch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String _normalizeUrl(String raw) {
    final t = raw.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    return 'https://$t';
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}