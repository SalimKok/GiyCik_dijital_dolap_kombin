import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
      return Scaffold(
        appBar: AppBar(title: const Text('Hijyen & Yıkama')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hijyen & Yıkama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kullanım Sınırı Hakkında'),
                  content: const Text(
                    'Kıyafetlerinizin türüne göre belirlenen kullanım sınırlarına ulaşıldığında, o kıyafet otomatik olarak kirliler (Yıkanması Gerekenler) listesine düşer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Anladım'),
                    )
                  ],
                ),
              );
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: [
            Tab(text: 'Kirliler (${laundryState.needsWashItems.length})', icon: const Icon(Icons.warning_amber_rounded)),
            Tab(text: 'Yıkanıyor (${laundryState.washingItems.length})', icon: const Icon(Icons.local_laundry_service_rounded)),
            Tab(text: 'Temiz (${laundryState.cleanItems.length})', icon: const Icon(Icons.check_circle_outline_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLaundryList(laundryState.needsWashItems, 'Kirli Sepeti Boş', 'Harika! Yıkanmayı bekleyen kıyafetin yok.', LaundryStatus.needsWash, theme),
          _buildLaundryList(laundryState.washingItems, 'Makine Boş', 'Şu an yıkanan bir kıyafet bulunmuyor.', LaundryStatus.washing, theme),
          _buildLaundryList(laundryState.cleanItems, 'Temiz Kıyafet Yok', 'Dolabında giyilmeye hazır kıyafetin kalmamış gibi görünüyor.', LaundryStatus.clean, theme),
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
                status == LaundryStatus.needsWash ? Icons.check_circle_outline_rounded :
                status == LaundryStatus.washing ? Icons.local_laundry_service_rounded :
                Icons.dry_cleaning_rounded,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(status, theme),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: _getIconColor(status, theme), size: 28),
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
                  Row(
                    children: [
                      Text(
                        item.category,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status == LaundryStatus.clean
                          ? '${item.maxWear - item.wearCount} kullanım kaldı'
                          : 'Kullanım sınırı doldu',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: status == LaundryStatus.clean ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.error,
                          fontWeight: status == LaundryStatus.clean ? FontWeight.normal : FontWeight.bold,
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
      return IconButton.filled(
        onPressed: () {
          ref.read(laundryViewModelProvider.notifier).moveToWashing(item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name} yıkamaya eklendi')),
          );
        },
        icon: const Icon(Icons.local_laundry_service_rounded),
        tooltip: 'Yıkamaya At',
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
        ),
      );
    } else if (status == LaundryStatus.washing) {
      return IconButton.filled(
        onPressed: () {
          ref.read(laundryViewModelProvider.notifier).moveToClean(item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name} temiz olarak işaretlendi')),
          );
        },
        icon: const Icon(Icons.check_rounded),
        tooltip: 'Temiz Olarak İşaretle',
        style: IconButton.styleFrom(
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green.shade800,
        ),
      );
    } else {
      return IconButton.outlined(
        onPressed: () {
          ref.read(laundryViewModelProvider.notifier).moveToNeedsWash(item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name} kirlilere eklendi')),
          );
        },
        icon: const Icon(Icons.water_drop_rounded),
        tooltip: 'Kirlilere Taşı',
        style: IconButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
        ),
      );
    }
  }

  Color _getIconBackgroundColor(LaundryStatus status, ThemeData theme) {
    if (status == LaundryStatus.needsWash) return theme.colorScheme.errorContainer.withValues(alpha: 0.5);
    if (status == LaundryStatus.washing) return theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
    return Colors.green.shade50;
  }

  Color _getIconColor(LaundryStatus status, ThemeData theme) {
    if (status == LaundryStatus.needsWash) return theme.colorScheme.error;
    if (status == LaundryStatus.washing) return theme.colorScheme.primary;
    return Colors.green.shade700;
  }
}
