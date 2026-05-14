import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/constants/api_constants.dart';

class RecommendationPreview extends ConsumerWidget {
  final Map<String, dynamic> recommendation;
  final List<dynamic> wardrobeItems;

  const RecommendationPreview({
    super.key,
    required this.recommendation,
    required this.wardrobeItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // ID'leri topla
    final ids = [
      recommendation['top_id'],
      recommendation['bottom_id'],
      recommendation['outerwear_id'],
      recommendation['shoes_id'],
      recommendation['shawl_id'],
    ].where((id) => id != null).cast<String>().toList();

    final matchedClothes = ids.map((id) {
      return wardrobeItems.where((w) => w.id == id).firstOrNull;
    }).where((item) => item != null).toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Önerilen Kombin',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: matchedClothes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = matchedClothes[index];
                final String? imageUrl = item?.imageUrl != null && item!.imageUrl!.isNotEmpty
                    ? (item.imageUrl!.startsWith('http') 
                        ? item.imageUrl! 
                        : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}')
                    : null;

                return AspectRatio(
                  aspectRatio: 0.75, // Biraz dikey dikdörtgen daha şık durur
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null 
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.checkroom_rounded,
                              size: 40,
                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation['description'] ?? 'Harika bir kombin!',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
