import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/core/constants/api_constants.dart';
import 'package:gircik/data/models/outfit_item.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/features/style_calendar/view/utils/calendar_dialogs.dart';

class CalendarEventCard extends ConsumerWidget {
  final CalendarEvent event;
  const CalendarEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final outfitsState = ref.watch(outfitsViewModelProvider);
    final wardrobeItems = ref.watch(wardrobeViewModelProvider).items;

    // Find matched outfit
    OutfitItem? linkedOutfit;
    if (event.outfitId != null) {
      linkedOutfit = outfitsState.outfits.where((o) => o.id == event.outfitId).firstOrNull;
    }

    // Get clothing images for the outfit
    List<String> outfitImageUrls = [];
    if (linkedOutfit != null) {
      for (final outfitPiece in linkedOutfit.items) {
        final cloth = wardrobeItems.where((w) => w.id == outfitPiece.clothingItemId).firstOrNull;
        if (cloth?.imageUrl != null && cloth!.imageUrl!.isNotEmpty) {
          final url = cloth.imageUrl!.startsWith('http')
              ? cloth.imageUrl!
              : '${ApiConstants.baseUrl.replaceAll('/api', '')}${cloth.imageUrl}';
          outfitImageUrls.add(url);
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    linkedOutfit != null ? Icons.checkroom_rounded : Icons.event_note_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        linkedOutfit != null ? linkedOutfit.title : 'Kombin seçilmedi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: linkedOutfit != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: linkedOutfit != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    if (value == 'edit') {
                      CalendarDialogs.showEventDialog(context, ref, existingEvent: event);
                    } else if (value == 'delete') {
                      CalendarDialogs.showDeleteDialog(context, ref, event);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20),
                          SizedBox(width: 12),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 20, color: theme.colorScheme.error),
                          const SizedBox(width: 12),
                          Text('Sil', style: TextStyle(color: theme.colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Show outfit images if available
          if (outfitImageUrls.isNotEmpty)
            Container(
              height: 72,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: outfitImageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Container(
                    width: 56,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      outfitImageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.checkroom_rounded,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
