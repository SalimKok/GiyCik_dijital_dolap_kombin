import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/travel/viewmodel/travel_viewmodel.dart';
import 'package:gircik/features/travel/view/create_travel_screen.dart';
import 'package:gircik/features/travel/view/travel_detail_screen.dart';
import 'package:gircik/data/models/travel_plan.dart';
import 'package:uuid/uuid.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';

class TravelAssistantScreen extends ConsumerWidget {
  const TravelAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travelState = ref.watch(travelViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: travelState.isLoading && travelState.plans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : travelState.plans.isEmpty
              ? _buildEmptyState(context, theme)
              : RefreshIndicator(
                  onRefresh: () => ref.read(travelViewModelProvider.notifier).loadPlans(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: travelState.plans.length,
                    itemBuilder: (context, index) {
                      final plan = travelState.plans[index];
                      return _buildPlanCard(context, theme, plan, ref);
                    },
                  ),
                ),
      floatingActionButton: travelState.plans.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTravelScreen()));
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Yeni Seyahat'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight_takeoff_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(
              'Yaklaşan seyahatiniz var mı?',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Gideceğiniz yeri ve tarihleri söyleyin, yapay zeka asistanınız sizin için en uygun valizi hazırlasın.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTravelScreen()));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Valiz Hazırla'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, ThemeData theme, TravelPlan plan, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TravelDetailScreen(plan: plan)));
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${plan.destination} Seyahati',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar_rounded, color: Colors.blue),
                    onPressed: () => _addToCalendar(context, ref, plan),
                    tooltip: 'Takvime Ekle',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () {
                      _showDeleteDialog(context, ref, plan.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.date_range_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    '${plan.startDate} - ${plan.endDate}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.card_travel_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    plan.purpose,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Bu seyahat planını silmek istiyor musunuz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              ref.read(travelViewModelProvider.notifier).deletePlan(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
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
        
        final latestState = ref.read(styleCalendarViewModelProvider);
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
