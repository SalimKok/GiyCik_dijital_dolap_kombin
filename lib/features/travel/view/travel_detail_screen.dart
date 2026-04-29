import 'package:flutter/material.dart';
import 'package:gircik/data/models/travel_plan.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';
class TravelDetailScreen extends ConsumerWidget {
  final TravelPlan plan;

  const TravelDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itinerary = plan.itinerary;
    final summary = itinerary['summary'] ?? '';
    final packingList = (itinerary['packing_list'] as List?)?.cast<String>() ?? [];
    final days = (itinerary['days'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.destination),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_rounded),
            tooltip: 'Takvime Ekle',
            onPressed: () => _addToCalendar(context, ref, plan),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addToCalendar(context, ref, plan),
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Bu Seyahati Takvime Ekle'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (summary.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        summary,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (packingList.isNotEmpty) ...[
              Text('Genel Valiz Listesi', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: packingList.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text('Günlük Kombinler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...days.map((dayData) => _buildDayCard(context, theme, dayData, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, ThemeData theme, dynamic dayData, WidgetRef ref) {
    final dayNum = dayData['day'];
    final title = dayData['title'] ?? 'Gün $dayNum Kombini';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$dayNum', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildOutfitItemRow(theme, 'Üst Giyim', dayData['top_id'], Icons.dry_cleaning_rounded, ref),
            _buildOutfitItemRow(theme, 'Alt Giyim', dayData['bottom_id'], Icons.airline_seat_legroom_normal_rounded, ref),
            _buildOutfitItemRow(theme, 'Dış Giyim', dayData['outerwear_id'], Icons.dry_cleaning, ref),
            _buildOutfitItemRow(theme, 'Ayakkabı', dayData['shoes_id'], Icons.snowshoeing_rounded, ref),
            _buildOutfitItemRow(theme, 'Aksesuar', dayData['accessory_id'], Icons.watch_rounded, ref),
            _buildOutfitItemRow(theme, 'Şal/Eşarp', dayData['shawl_id'], Icons.checkroom_rounded, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitItemRow(ThemeData theme, String label, String? id, IconData icon, WidgetRef ref) {
    if (id == null || id.isEmpty || id == 'null') return const SizedBox.shrink();
    
    final wardrobeState = ref.read(wardrobeViewModelProvider);
    final item = wardrobeState.items.where((i) => i.id == id).firstOrNull;
    final itemName = item?.name ?? 'Bilinmeyen Eşya ($label)';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(itemName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _addToCalendar(BuildContext context, WidgetRef ref, TravelPlan plan) async {
    try {
      final startDate = DateTime.parse(plan.startDate);
      final endDate = DateTime.parse(plan.endDate);
      final days = endDate.difference(startDate).inDays + 1;
      
      final calendarNotifier = ref.read(styleCalendarViewModelProvider.notifier);
      int addedCount = 0;
      
      for (int i = 0; i < days; i++) {
        final currentDay = startDate.add(Duration(days: i));
        final title = '✈️ ${plan.destination} Seyahati (${i + 1}. Gün)';
        
        // Yenilenmiş state'i her adımda okuyarak hızlı çift tıklamaları ve önceki eklemeleri yakala
        final latestState = ref.read(styleCalendarViewModelProvider);
        
        // Timezone farklılıklarından dolayı tarihler kaymış olabilir, sadece başlığa ve yakın tarihe bakıyoruz.
        final alreadyExists = latestState.events.any((e) => 
            e.title == title && e.date.difference(currentDay).inHours.abs() <= 36
        );
        
        if (!alreadyExists) {
          final newEvent = CalendarEvent(
            id: const Uuid().v4(),
            date: currentDay,
            title: title,
          );
          await calendarNotifier.addEvent(newEvent);
          addedCount++;
        }
      }
      
      if (addedCount > 0) {
        ref.read(homeViewModelProvider.notifier).loadHomeData();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$addedCount günlük seyahat takvime eklendi.')));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu seyahat zaten takvimde mevcut.')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }
}
