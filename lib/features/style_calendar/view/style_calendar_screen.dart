import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/core/constants/api_constants.dart';
import 'package:gircik/data/models/outfit_item.dart';

import '../../../data/models/calendar_event.dart';
import '../../subscription/view/pro_paywall_screen.dart';
import '../../subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/data/models/subscription.dart';

class StyleCalendarScreen extends ConsumerStatefulWidget {
  const StyleCalendarScreen({super.key});

  @override
  ConsumerState<StyleCalendarScreen> createState() => _StyleCalendarScreenState();
}

class _StyleCalendarScreenState extends ConsumerState<StyleCalendarScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calState = ref.watch(styleCalendarViewModelProvider);

    if (calState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final selectedEvents = calState.getEventsForDay(calState.selectedDay!);

    return Scaffold(
      body: Column(
        children: [
          _buildCalendar(theme, calState),
          const SizedBox(height: 16),
          Expanded(
            child: _buildEventList(theme, calState, selectedEvents),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showEventDialog(context);
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Not Ekle'),
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme, StyleCalendarState calState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: calState.focusedDay,
        calendarFormat: calState.calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(calState.selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(calState.selectedDay, selectedDay)) {
            ref.read(styleCalendarViewModelProvider.notifier).selectDay(selectedDay, focusedDay);
          }
        },
        onFormatChanged: (format) {
          if (calState.calendarFormat != format) {
            ref.read(styleCalendarViewModelProvider.notifier).changeFormat(format);
          }
        },
        onPageChanged: (focusedDay) {
          ref.read(styleCalendarViewModelProvider.notifier).changePage(focusedDay);
        },
        eventLoader: (day) => calState.getEventsForDay(day),
        locale: 'tr_TR',
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(Icons.chevron_left_rounded, color: theme.colorScheme.onSurface),
          rightChevronIcon: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: theme.colorScheme.error),
          holidayTextStyle: TextStyle(color: theme.colorScheme.error),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w500),
          weekdayStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildEventList(ThemeData theme, StyleCalendarState calState, List events) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMMM yyyy', 'tr_TR').format(calState.selectedDay!),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${events.length} Kayıt',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index] as CalendarEvent;
                      return _buildEventCard(theme, event);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(ThemeData theme, CalendarEvent event) {
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
                    color: Colors.white,
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
                      _showEventDialog(context, existingEvent: event);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, event);
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Bu tarih için plan yok',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir kombin planlamak için + butonunu kullanın.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEventDialog(BuildContext context, {CalendarEvent? existingEvent}) {
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

  void _showDeleteDialog(BuildContext context, CalendarEvent event) {
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
