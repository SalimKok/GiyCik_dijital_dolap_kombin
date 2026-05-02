import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/wardrobe/view/clothing_capture_screen.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/core/constants/api_constants.dart';

import '../../subscription/view/pro_paywall_screen.dart';
import '../../subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/data/models/subscription.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wardrobeState = ref.watch(wardrobeViewModelProvider);

    return Scaffold(
      body: wardrobeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryRow(context, theme, wardrobeState.filteredItems.length),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: GridView.builder(
                      itemCount: wardrobeState.filteredItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final item = wardrobeState.filteredItems[index];
                        final laundryState = ref.watch(laundryViewModelProvider);
                        final dirtyItemIds = laundryState.needsWashItems.map((i) => i.clothingItemId).toSet();
                        final isDirty = dirtyItemIds.contains(item.id);
                        
                        return _WardrobeCard(item: item, isDirty: isDirty);
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final isPro = ref.read(subscriptionProvider).isPro;
          final currentCount = ref.read(wardrobeViewModelProvider).items.length;
          final canAdd = isPro || currentCount < FreeLimits.maxClothingItems;
          
          if (canAdd) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ClothingCaptureScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ücretsiz kıyafet ekleme limitine ulaştınız. Sınırsız kullanım için Pro\'ya geçin.'),
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProPaywallScreen(),
              ),
            );
          }
        },
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Yeni kıyafet ekle'),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, ThemeData theme, int visibleCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Text(
            '$visibleCount parça',
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // İleride gelişmiş filtre/sort için kullanılabilir
              showModalBottomSheet<void>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Consumer(
                    builder: (context, ref, child) {
                      final bottomSheetState = ref.watch(wardrobeViewModelProvider);
                      final sheetTheme = Theme.of(context);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kategoriler',
                              style: sheetTheme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: bottomSheetState.categories.map((c) {
                                final isSelected = c == bottomSheetState.selectedCategory;
                                return ChoiceChip(
                                  label: Text(c),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    ref.read(wardrobeViewModelProvider.notifier).selectCategory(c);
                                  },
                                  selectedColor: sheetTheme.colorScheme.primary.withValues(alpha: 0.15),
                                  labelStyle: sheetTheme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected
                                        ? sheetTheme.colorScheme.primary
                                        : sheetTheme.colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? sheetTheme.colorScheme.primary
                                        : sheetTheme.colorScheme.outline.withValues(alpha: 0.7),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Colors.white,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Renkler',
                              style: sheetTheme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: bottomSheetState.availableColors.map((color) {
                                final isSelected = color == bottomSheetState.selectedColor;
                                return ChoiceChip(
                                  label: Text(color),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    ref.read(wardrobeViewModelProvider.notifier).selectColor(color);
                                  },
                                  selectedColor: sheetTheme.colorScheme.primary.withValues(alpha: 0.15),
                                  labelStyle: sheetTheme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected
                                        ? sheetTheme.colorScheme.primary
                                        : sheetTheme.colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? sheetTheme.colorScheme.primary
                                        : sheetTheme.colorScheme.outline.withValues(alpha: 0.7),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Colors.white,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('Filtrele'),
          ),
        ],
      ),
    );
  }
}

class _WardrobeCard extends ConsumerWidget {
  const _WardrobeCard({required this.item, this.isDirty = false});

  final ClothingItem item;
  final bool isDirty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Construct full URL using base URL (stripping '/api' since item.imageUrl starts with '/api/')
    final String? fullImageUrl = item.imageUrl != null && item.imageUrl!.isNotEmpty
        ? '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}'
        : null;

    return Material(
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape as RoundedRectangleBorder,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showItemDetails(context, ref, theme, fullImageUrl),
        child: Padding(
          padding: const EdgeInsets.all(8), // Küçültüldü
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      fullImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                fullImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(theme),
                              ),
                            )
                          : _buildFallbackIcon(theme),
                      
                      if (isDirty)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.water_drop_rounded, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.category} • ${item.color}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, WidgetRef ref, ThemeData theme, String? fullImageUrl) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, 
            right: 20, 
            top: 24, 
            bottom: MediaQuery.of(context).padding.bottom + 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: fullImageUrl != null
                        ? Image.network(fullImageUrl, fit: BoxFit.cover)
                        : _buildFallbackIcon(theme),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${item.category} • ${item.color}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat_rounded, size: 16, color: theme.colorScheme.onSecondaryContainer),
                              const SizedBox(width: 6),
                              Text('${item.usageCount} kez giyildi', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Kıyafeti Sil'),
                            content: const Text('Bu kıyafeti silmek istediğinizden emin misiniz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('İptal'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Sil'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          try {
                            await ref.read(wardrobeViewModelProvider.notifier).deleteItem(item.id);
                            if (context.mounted) {
                              Navigator.pop(context); // Close bottom sheet
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kıyafet başarıyla silindi.')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Hata: $e')),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Sil'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClothingCaptureScreen(existingItem: item),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Düzenle'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildFallbackIcon(ThemeData theme) {
    return Icon(
      Icons.checkroom_rounded,
      color: theme.colorScheme.primary,
      size: 32,
    );
  }
}

