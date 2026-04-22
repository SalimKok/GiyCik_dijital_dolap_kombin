import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/constants/api_constants.dart';
import 'package:gircik/data/models/laundry_item.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';

class LaundryScreen extends ConsumerStatefulWidget {
  const LaundryScreen({super.key});

  @override
  ConsumerState<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends ConsumerState<LaundryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final laundryState = ref.watch(laundryViewModelProvider);

    if (laundryState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: [
            Tab(
              text: 'Temiz (${laundryState.cleanItems.length})',
              icon: const Icon(Icons.check_circle_outline_rounded),
            ),
            Tab(
              text: 'Kirli (${laundryState.needsWashItems.length})',
              icon: const Icon(Icons.warning_amber_rounded),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLaundryList(
            laundryState.cleanItems,
            'Temiz Kıyafet Yok',
            'Dolabında giyilmeye hazır kıyafetin kalmamış gibi görünüyor.',
            LaundryStatus.clean,
            theme,
          ),
          _buildLaundryList(
            laundryState.needsWashItems,
            'Kirli Sepeti Boş',
            'Harika! Yıkanmayı bekleyen kıyafetin yok.',
            LaundryStatus.needsWash,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildLaundryList(List<LaundryItem> items, String emptyTitle, String emptySubtitle, LaundryStatus status, ThemeData theme) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == LaundryStatus.needsWash
                    ? Icons.check_circle_outline_rounded
                    : Icons.dry_cleaning_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                emptyTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item, status, theme);
      },
    );
  }

  Widget _buildItemCard(LaundryItem item, LaundryStatus status, ThemeData theme) {
    // Construct image URL
    final String? fullImageUrl = item.imageUrl != null && item.imageUrl!.isNotEmpty
        ? (item.imageUrl!.startsWith('http')
            ? item.imageUrl!
            : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}')
        : null;

    final wearProgress = item.maxWear > 0 ? item.wearCount / item.maxWear : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Clothing image or icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(status, theme),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: fullImageUrl != null
                  ? Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(item.icon, color: _getIconColor(status, theme), size: 28),
                    )
                  : Icon(item.icon, color: _getIconColor(status, theme), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  // Wear progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: wearProgress,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: wearProgress >= 1.0
                                ? theme.colorScheme.error
                                : wearProgress >= 0.66
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.wearCount}/${item.maxWear}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: wearProgress >= 1.0 ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActionButton(item, status, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(LaundryItem item, LaundryStatus status, ThemeData theme) {
    if (status == LaundryStatus.needsWash) {
      // In dirty tab → button to mark as clean (washed)
      return FilledButton.icon(
        onPressed: () {
          ref.read(laundryViewModelProvider.notifier).moveToClean(item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name} yıkandı, temiz olarak işaretlendi')),
          );
        },
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text('Yıkandı'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else {
      // In clean tab → two actions: "Giydim" (main) and "Kirli" (secondary)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: () {
              final remaining = item.maxWear - item.wearCount - 1;
              ref.read(laundryViewModelProvider.notifier).incrementWear(item.id);
              if (remaining <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} yıkanması gerekiyor!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} giyildi • $remaining kullanım kaldı')),
                );
              }
            },
            icon: const Icon(Icons.accessibility_new_rounded, size: 18),
            label: const Text('Giydim'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      );
    }
  }

  Color _getIconBackgroundColor(LaundryStatus status, ThemeData theme) {
    if (status == LaundryStatus.needsWash) return theme.colorScheme.errorContainer.withValues(alpha: 0.5);
    return Colors.green.shade50;
  }

  Color _getIconColor(LaundryStatus status, ThemeData theme) {
    if (status == LaundryStatus.needsWash) return theme.colorScheme.error;
    return Colors.green.shade700;
  }
}
