import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/style_calendar/view/widgets/add_note_button.dart';
import 'package:gircik/features/style_calendar/view/widgets/calendar_event_card.dart';
import 'package:gircik/features/style_calendar/view/utils/calendar_dialogs.dart';

class CalendarEventList extends ConsumerWidget {
  final StyleCalendarState calState;
  final List<dynamic> events;

  const CalendarEventList({super.key, required this.calState, required this.events});

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.cardTheme.color ?? theme.colorScheme.surface,
            theme.colorScheme.surface,
          ],
        ),
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
            padding: const EdgeInsets.fromLTRB(24, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('d MMMM yyyy', 'tr_TR').format(calState.selectedDay!),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${events.length} kayıt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                AddNoteButton(onTap: () => CalendarDialogs.showEventDialog(context, ref)),
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
                      return CalendarEventCard(event: event);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
