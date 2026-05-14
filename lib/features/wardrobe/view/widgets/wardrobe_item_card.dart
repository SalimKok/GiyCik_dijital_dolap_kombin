import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/constants/api_constants.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/features/wardrobe/view/widgets/wardrobe_item_details_sheet.dart';

class WardrobeItemCard extends ConsumerWidget {
  const WardrobeItemCard({super.key, required this.item, this.isDirty = false});

  final ClothingItem item;
  final bool isDirty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Construct full URL using base URL
    final String? fullImageUrl = item.imageUrl != null && item.imageUrl!.isNotEmpty
        ? '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}'
        : null;

    return Material(
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape as RoundedRectangleBorder,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showWardrobeItemDetailsSheet(context, ref, item, fullImageUrl),
        child: Padding(
          padding: const EdgeInsets.all(8),
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

  Widget _buildFallbackIcon(ThemeData theme) {
    return Icon(
      Icons.checkroom_rounded,
      color: theme.colorScheme.primary,
      size: 32,
    );
  }
}
