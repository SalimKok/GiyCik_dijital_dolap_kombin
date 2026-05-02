import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/outfits/view/outfit_recommendation_screen.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/data/models/outfit_item.dart';
import 'package:gircik/core/constants/api_constants.dart';
import '../../subscription/view/pro_paywall_screen.dart';
import '../../subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/data/models/subscription.dart';

class OutfitsScreen extends ConsumerStatefulWidget {
  const OutfitsScreen({super.key});

  @override
  ConsumerState<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends ConsumerState<OutfitsScreen> with SingleTickerProviderStateMixin {
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
    final outfitsState = ref.watch(outfitsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Tüm Kombinler'),
                    Tab(text: 'Favoriler'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(Icons.filter_list_rounded),
                  tooltip: 'Filtrele',
                ),
              ),
            ],
          ),
        ),
      ),
      body: outfitsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOutfitsList(
                  outfitsState.filteredOutfits,
                  'Henüz kombin eklemedin.',
                  'Yeni bir kombin oluşturarak başla!',
                  theme,
                ),
                _buildOutfitsList(
                  outfitsState.favoriteOutfits,
                  'Favori kombinin yok.',
                  'Beğendiğin kombinleri favorilerine ekle.',
                  theme,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final isPro = ref.read(subscriptionProvider).isPro;
          final currentCount = ref.read(outfitsViewModelProvider).outfits.length;
          final canAdd = isPro || currentCount < FreeLimits.maxOutfits;
          
          if (canAdd) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OutfitRecommendationScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ücretsiz kombin oluşturma limitine ulaştınız. Sınırsız kullanım için Pro\'ya geçin.'),
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
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Öneri Al'),
      ),
    );
  }

  Widget _buildOutfitsList(List<OutfitItem> list, String emptyTitle, String emptySubtitle, ThemeData theme) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text(emptyTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(emptySubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12), // Boşluk azaltıldı
      itemBuilder: (context, index) {
        final outfit = list[index];
        return _buildOutfitCard(outfit, theme);
      },
    );
  }

  Widget _buildOutfitCard(OutfitItem outfit, ThemeData theme) {
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
        borderRadius: BorderRadius.circular(16), // Biraz daha keskin
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2), // Belirgin border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Göze batmayan ama belirgin gölge
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Küçültüldü
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
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), // Küçültüldü
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
                      width: 36, // Buton alanları daraltıldı
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
                             _wearOutfit(context, outfit);
                          } else if (value == 'delete') {
                             _confirmDelete(context, outfit);
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
            padding: const EdgeInsets.all(12), // Küçültüldü
            child: matchedClothes.isNotEmpty
              ? Wrap(
                  spacing: 8, // Küçültüldü
                  runSpacing: 8,
                  children: matchedClothes.map((item) {
                    final String? imageUrl = item!.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? (item.imageUrl!.startsWith('http') 
                            ? item.imageUrl! 
                            : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}')
                        : null;
                    return Container(
                      width: 54, // Küçültüldü (önceki 76)
                      height: 72, // Küçültüldü (önceki 100)
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

  void _confirmDelete(BuildContext context, OutfitItem outfit) {
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
                if (mounted) {
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

  void _wearOutfit(BuildContext context, OutfitItem outfit) {
    ref.read(outfitsViewModelProvider.notifier).wearOutfit(outfit.id).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${outfit.title} giyildi! Kıyafetlerin giyim sayacı güncellendi.')),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${error.toString()}')),
        );
      }
    });
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(outfitsViewModelProvider);
            final theme = Theme.of(context);
            
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kombinleri Filtrele', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Tarz', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.styles.map((style) {
                      final isSelected = state.selectedStyle == style;
                      return ChoiceChip(
                        label: Text(style),
                        selected: isSelected,
                        onSelected: (_) => ref.read(outfitsViewModelProvider.notifier).selectStyle(style),
                        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text('Mevsim', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.seasons.map((season) {
                      final isSelected = state.selectedSeason == season;
                      return ChoiceChip(
                        label: Text(season),
                        selected: isSelected,
                        onSelected: (_) => ref.read(outfitsViewModelProvider.notifier).selectSeason(season),
                        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
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
  }
}
