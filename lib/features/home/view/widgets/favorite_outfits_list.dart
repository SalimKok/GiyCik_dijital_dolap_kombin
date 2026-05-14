import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/constants/api_constants.dart';
import 'package:gircik/data/models/outfit_item.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';

class FavoriteOutfitsList extends ConsumerWidget {
  final List<OutfitItem> favorites;

  const FavoriteOutfitsList({super.key, required this.favorites});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wardrobeItems = ref.watch(wardrobeViewModelProvider).items;

    if (favorites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Henüz favori kombininiz yok.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: favorites.length,
      separatorBuilder: (context, index) => const SizedBox(width: 6),
      itemBuilder: (context, index) {
        final outfit = favorites[index];

        // Kombindeki kıyafet resimlerini bul
        final outfitImages = outfit.items.map((link) {
          final item = wardrobeItems.where((w) => w.id == link.clothingItemId).firstOrNull;
          if (item?.imageUrl != null && item!.imageUrl!.isNotEmpty) {
            return item.imageUrl!.startsWith('http')
                ? item.imageUrl!
                : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}';
          }
          return null;
        }).where((url) => url != null).cast<String>().toList();

        return AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 22,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dinamik grid resim bölümü
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              _buildOutfitImageGrid(outfitImages, theme),
                              // Favori rozeti
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade500,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.favorite_rounded, size: 11, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        outfit.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        outfit.style,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Parça sayısına göre alanı bölen dinamik grid
  Widget _buildOutfitImageGrid(List<String> images, ThemeData theme) {
    if (images.isEmpty) return _buildOutfitPlaceholder(theme);

    Widget imageCell(String url) => Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildOutfitPlaceholder(theme),
        );

    // 1 parça → tam alan
    if (images.length == 1) {
      return SizedBox.expand(child: imageCell(images[0]));
    }

    // 2 parça → yan yana eşit
    if (images.length == 2) {
      return Row(
        children: [
          Expanded(child: imageCell(images[0])),
          const SizedBox(width: 2),
          Expanded(child: imageCell(images[1])),
        ],
      );
    }

    // 3 parça → sol büyük + sağ 2 küçük alt alta
    if (images.length == 3) {
      return Row(
        children: [
          Expanded(flex: 3, child: imageCell(images[0])),
          const SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(child: imageCell(images[1])),
                const SizedBox(height: 2),
                Expanded(child: imageCell(images[2])),
              ],
            ),
          ),
        ],
      );
    }

    // 4+ parça → 2×2 grid (max 4 göster)
    final show = images.take(4).toList();
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: imageCell(show[0])),
              const SizedBox(width: 2),
              Expanded(child: imageCell(show[1])),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: imageCell(show[2])),
              const SizedBox(width: 2),
              Expanded(
                child: show.length > 3
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          imageCell(show[3]),
                          // 4'ten fazla varsa "+N" göster
                          if (images.length > 4)
                            Container(
                              color: Colors.black54,
                              child: Center(
                                child: Text(
                                  '+${images.length - 4}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : _buildOutfitPlaceholder(theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 40,
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
