import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/data/models/subscription.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';
import 'package:gircik/core/constants/api_constants.dart';

class CalendarDialogs {
  static void showEventDialog(BuildContext context, WidgetRef ref, {CalendarEvent? existingEvent}) {
    final textController = TextEditingController(text: existingEvent?.title ?? '');
    String? selectedOutfitId = existingEvent?.outfitId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final outfits = ref.read(outfitsViewModelProvider).outfits;
            final wardrobeItems = ref.read(wardrobeViewModelProvider).items;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existingEvent != null ? 'Planı Düzenle' : 'Yeni Plan Ekle',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Örn: Doğum Günü Yemeği',
                      labelText: 'Etkinlik Notu',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),

                  // Outfit selection
                  Text(
                    'Kombin Seç (İsteğe Bağlı)',
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: outfits.isEmpty
                        ? Center(
                            child: Text(
                              'Henüz kombininiz yok.',
                              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: outfits.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (ctx2, index) {
                              final outfit = outfits[index];
                              final isSelected = selectedOutfitId == outfit.id;

                              // Get first clothing image for preview
                              String? previewUrl;
                              if (outfit.items.isNotEmpty) {
                                final firstCloth = wardrobeItems
                                    .where((w) => w.id == outfit.items.first.clothingItemId)
                                    .firstOrNull;
                                if (firstCloth?.imageUrl != null && firstCloth!.imageUrl!.isNotEmpty) {
                                  previewUrl = firstCloth.imageUrl!.startsWith('http')
                                      ? firstCloth.imageUrl!
                                      : '${ApiConstants.baseUrl.replaceAll('/api', '')}${firstCloth.imageUrl}';
                                }
                              }

                              return GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    selectedOutfitId = isSelected ? null : outfit.id;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(ctx2).colorScheme.primary
                                          : Theme.of(ctx2).colorScheme.primary.withValues(alpha: 0.3),
                                      width: isSelected ? 2.5 : 1.5,
                                    ),
                                    color: isSelected
                                        ? Theme.of(ctx2).colorScheme.primary.withValues(alpha: 0.08)
                                        : Theme.of(ctx2).colorScheme.surfaceContainer,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: previewUrl != null
                                            ? Image.network(
                                                previewUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (_, __, ___) => Icon(
                                                  Icons.checkroom_rounded,
                                                  color: Theme.of(ctx2).colorScheme.primary.withValues(alpha: 0.5),
                                                ),
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.checkroom_rounded,
                                                  size: 32,
                                                  color: Theme.of(ctx2).colorScheme.primary.withValues(alpha: 0.5),
                                                ),
                                              ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                        color: isSelected
                                            ? Theme.of(ctx2).colorScheme.primary.withValues(alpha: 0.12)
                                            : null,
                                        child: Text(
                                          outfit.title,
                                          style: Theme.of(ctx2).textTheme.bodySmall?.copyWith(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 11,
                                            color: isSelected
                                                ? Theme.of(ctx2).colorScheme.primary
                                                : null,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final title = textController.text.trim();
                        if (title.isNotEmpty) {
                          if (existingEvent != null) {
                            final updatedEvent = existingEvent.copyWith(
                              title: title,
                              outfitId: selectedOutfitId,
                            );
                            ref.read(styleCalendarViewModelProvider.notifier).updateEvent(updatedEvent);
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Not güncellendi!')),
                            );
                            return;
                          }

                          final isPro = ref.read(subscriptionProvider).isPro;
                          final currentCount = ref.read(styleCalendarViewModelProvider).events.length;
                          final canAdd = isPro || currentCount < FreeLimits.maxCalendarEvents;
                          
                          if (!canAdd) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ücretsiz takvim etkinliği ekleme limitine ulaştınız. Sınırsız kullanım için Pro\'ya geçin.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ProPaywallScreen(),
                              ),
                            );
                            return;
                          }

                          final selectedDay = ref.read(styleCalendarViewModelProvider).selectedDay ?? DateTime.now();
                          final event = CalendarEvent(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            date: selectedDay,
                            title: title,
                            outfitId: selectedOutfitId,
                          );
                          ref.read(styleCalendarViewModelProvider.notifier).addEvent(event);
                          
                          // Increment usage count
                          ref.read(subscriptionProvider.notifier).incrementCalendarEventCount();
                          
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Not eklendi!')),
                          );
                        }
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showDeleteDialog(BuildContext context, WidgetRef ref, CalendarEvent event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Bu takvim notunu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(styleCalendarViewModelProvider.notifier).deleteEvent(event.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not silindi!')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
