import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'dart:io';

class WardrobeAnalyticsScreen extends ConsumerWidget {
  const WardrobeAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobeState = ref.watch(wardrobeViewModelProvider);
    final theme = Theme.of(context);

    if (wardrobeState.isLoading && wardrobeState.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wardrobeState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(
              'Henüz Veri Yok',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Analitikleri görebilmek için gardırobunuza kıyafet ekleyin.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final totalItems = wardrobeState.items.length;
    final topWorn = _getTopWornItems(wardrobeState.items, 3);
    final leastWorn = _getLeastWornItems(wardrobeState.items, 3);
    final categoryStats = _getCategoryDistribution(wardrobeState.items);
    final colorStats = _getColorDistribution(wardrobeState.items);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet Kartı
          _buildSummaryCard(theme, totalItems),
          const SizedBox(height: 24),

          // En Çok Giyilenler
          if (topWorn.isNotEmpty && topWorn.first.usageCount > 0) ...[
            Text('En Çok Giyilenler', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topWorn.length,
                itemBuilder: (context, index) {
                  return _buildClothingCard(theme, topWorn[index], isTop: true);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Az Giyilenler
          if (leastWorn.isNotEmpty) ...[
            Text('Unutulan / Az Giyilenler', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: leastWorn.length,
                itemBuilder: (context, index) {
                  return _buildClothingCard(theme, leastWorn[index], isTop: false);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Kategori Dağılımı
          Text('Kategori Dağılımı', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDistributionCard(theme, categoryStats, totalItems),
          const SizedBox(height: 24),

          // Renk Dağılımı
          Text('Renk Dağılımı', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDistributionCard(theme, colorStats, totalItems),
          const SizedBox(height: 40), // Alt boşluk
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.checkroom_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Toplam Kıyafet',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingCard(ThemeData theme, ClothingItem item, {required bool isTop}) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? (item.imageUrl!.startsWith('http')
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                      : Image.file(File(item.imageUrl!), fit: BoxFit.cover))
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.checkroom, color: theme.colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isTop ? Icons.local_fire_department_rounded : Icons.ac_unit_rounded, 
                      size: 14, 
                      color: isTop ? Colors.orange.shade700 : Colors.blue.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.usageCount} kez',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(ThemeData theme, Map<String, int> stats, int total) {
    final sortedEntries = stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: sortedEntries.map((entry) {
          final percentage = total > 0 ? (entry.value / total) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.isEmpty ? 'Bilinmeyen' : entry.key,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: Colors.amber.shade600,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  List<ClothingItem> _getTopWornItems(List<ClothingItem> items, int count) {
    final sorted = List<ClothingItem>.from(items)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(count).toList();
  }

  List<ClothingItem> _getLeastWornItems(List<ClothingItem> items, int count) {
    final sorted = List<ClothingItem>.from(items)
      ..sort((a, b) => a.usageCount.compareTo(b.usageCount));
    return sorted.take(count).toList();
  }

  Map<String, int> _getCategoryDistribution(List<ClothingItem> items) {
    final map = <String, int>{};
    for (var item in items) {
      map[item.category] = (map[item.category] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> _getColorDistribution(List<ClothingItem> items) {
    final map = <String, int>{};
    for (var item in items) {
      map[item.color] = (map[item.color] ?? 0) + 1;
    }
    return map;
  }
}
