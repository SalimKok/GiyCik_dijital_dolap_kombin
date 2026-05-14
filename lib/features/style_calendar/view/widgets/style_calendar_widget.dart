import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';

class StyleCalendarWidget extends ConsumerWidget {
  final StyleCalendarState calState;

  const StyleCalendarWidget({super.key, required this.calState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.cardTheme.color ?? theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
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
}
