import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/data/models/outfit_item.dart';
import 'package:gircik/core/constants/api_constants.dart';
import 'package:gircik/features/outfits/view/outfit_recommendation_screen.dart';

class OutfitCard extends ConsumerWidget {
  final OutfitItem outfit;

  const OutfitCard({super.key, required this.outfit});

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kombini Sil'),
        content: const Text('Bu kombini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(outfitsViewModelProvider.notifier).deleteOutfit(outfit.id).catchError((error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _wearOutfit(BuildContext context, WidgetRef ref) {
    ref.read(outfitsViewModelProvider.notifier).wearOutfit(outfit.id).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${outfit.title} giyildi! Kıyafetlerin giyim sayacı güncellendi.')),
        );
      }
    }).catchError((error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${error.toString()}')),
        );
      }
    });
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    return Center(
      child: Icon(Icons.checkroom_rounded, color: theme.colorScheme.primary.withValues(alpha: 0.5), size: 32),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wardrobeItems = ref.watch(wardrobeViewModelProvider).items;
    final laundryState = ref.watch(laundryViewModelProvider);
    
    // Kombin parçalarını eşleştirip resimlerini bulalım
    final matchedClothes = outfit.items.map((outfitItem) {
        return wardrobeItems.where((w) => w.id == outfitItem.clothingItemId).firstOrNull;
    }).where((item) => item != null).toList();

    // Kirli kıyafetleri bulalım
    final dirtyItemIds = laundryState.needsWashItems.map((i) => i.clothingItemId).toSet();
    final hasDirtyItem = matchedClothes.any((cloth) => dirtyItemIds.contains(cloth!.id));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (hasDirtyItem)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.water_drop_rounded, size: 10, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kirli',
                                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                          _buildTag(outfit.style, theme.colorScheme.primary),
                          _buildTag(outfit.season, theme.colorScheme.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref.read(outfitsViewModelProvider.notifier).toggleFavorite(outfit.id);
                        },
                        icon: Icon(
                          outfit.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: outfit.isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                        onSelected: (value) {
                          if (value == 'edit') {
                             Navigator.of(context).push(
                               MaterialPageRoute(
                                 builder: (context) => OutfitRecommendationScreen(editingOutfit: outfit),
                               ),
                             );
                          } else if (value == 'wear') {
                             _wearOutfit(context, ref);
                          } else if (value == 'delete') {
                             _confirmDelete(context, ref);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'wear',
                            child: Row(
                              children: [
                                Icon(Icons.accessibility_new_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Giydim'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Düzenle'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded, size: 20, color: theme.colorScheme.error),
                                const SizedBox(width: 8),
                                Text('Sil', style: TextStyle(color: theme.colorScheme.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Items section with Images
          Padding(
            padding: const EdgeInsets.all(12),
            child: matchedClothes.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: matchedClothes.map((item) {
                    final String? imageUrl = item!.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? (item.imageUrl!.startsWith('http') 
                            ? item.imageUrl! 
                            : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}')
                        : null;
                    return Container(
                      width: 54,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl, 
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: SizedBox(
                                    width: 16, 
                                    height: 16, 
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2, 
                                      color: theme.colorScheme.primary.withValues(alpha: 0.5)
                                    )
                                  )
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(theme),
                            )
                          : _buildFallbackIcon(theme),
                    );
                  }).toList(),
                )
              : Text("Giysiler bulunamadı.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
