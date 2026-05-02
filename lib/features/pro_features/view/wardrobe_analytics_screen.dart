import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/core/constants/api_constants.dart';
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
            Text('En Çok Giyilenler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Biraz küçültüldü
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.65, // Daha dikey form
              ),
              itemCount: topWorn.length,
              itemBuilder: (context, index) {
                return _buildClothingCard(theme, topWorn[index], isTop: true);
              },
            ),
            const SizedBox(height: 24),
          ],

          // Az Giyilenler
          if (leastWorn.isNotEmpty) ...[
            Text('Unutulan / Az Giyilenler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.65,
              ),
              itemCount: leastWorn.length,
              itemBuilder: (context, index) {
                return _buildClothingCard(theme, leastWorn[index], isTop: false);
              },
            ),
            const SizedBox(height: 24),
          ],

          // Kategori Dağılımı
          Text('Kategori Dağılımı', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDistributionCard(theme, categoryStats, totalItems),
          const SizedBox(height: 24),

          // Renk Dağılımı
          Text('Renk Dağılımı', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDistributionCard(theme, colorStats, totalItems),
          const SizedBox(height: 40), // Alt boşluk
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Küçültüldü
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // Küçültüldü
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Küçültüldü
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.checkroom_rounded, color: Colors.white, size: 28), // Küçültüldü
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Toplam Kıyafet',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500), // Küçültüldü
                ),
                Text(
                  '$total',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), // Küçültüldü
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingCard(ThemeData theme, ClothingItem item, {required bool isTop}) {
    final String? fullImageUrl = item.imageUrl != null && item.imageUrl!.isNotEmpty
        ? (item.imageUrl!.startsWith('http') 
            ? item.imageUrl 
            : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}')
        : null;

    return Container(
      // Genişlik ve sağ boşluk kaldırıldı, GridView bunu yönetecek
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16), // Küçültüldü
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: fullImageUrl != null
                  ? Image.network(
                      fullImageUrl, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.checkroom, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.checkroom, color: theme.colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Küçültüldü
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold), // Küçültüldü
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isTop ? Icons.local_fire_department_rounded : Icons.ac_unit_rounded, 
                      size: 12, // Küçültüldü
                      color: isTop ? Colors.orange.shade700 : Colors.blue.shade400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${item.usageCount} kez',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10), // Küçültüldü
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
