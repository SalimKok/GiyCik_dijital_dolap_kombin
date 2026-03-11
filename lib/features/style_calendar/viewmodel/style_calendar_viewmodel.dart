import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gircik/data/models/calendar_event.dart';

// ViewModel State
class StyleCalendarState {
  final bool isLoading;
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<CalendarEvent> events;
  final String? error;

  StyleCalendarState({
    this.isLoading = false,
    this.calendarFormat = CalendarFormat.month,
    DateTime? focusedDay,
    this.selectedDay,
    this.events = const [],
    this.error,
  }) : focusedDay = focusedDay ?? DateTime.now();

  StyleCalendarState copyWith({
    bool? isLoading,
    CalendarFormat? calendarFormat,
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<CalendarEvent>? events,
    String? error,
  }) {
    return StyleCalendarState(
      isLoading: isLoading ?? this.isLoading,
      calendarFormat: calendarFormat ?? this.calendarFormat,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      events: events ?? this.events,
      error: error,
    );
  }

  /// Returns events matching the given [day].
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return events.where((e) => isSameDay(e.date, day)).toList();
  }
}

// ViewModel (Notifier)
class StyleCalendarViewModel extends Notifier<StyleCalendarState> {
  @override
  StyleCalendarState build() {
    final now = DateTime.now();
    Future.microtask(() => loadEvents());
    return StyleCalendarState(
      isLoading: true,
      focusedDay: now,
      selectedDay: now,
    );
  }

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final mockEvents = [
        CalendarEvent(
          id: '1',
          date: now.subtract(const Duration(days: 1)),
          title: 'İş Görüşmesi - Lacivert Takım',
        ),
        CalendarEvent(
          id: '2',
          date: now,
          title: 'Akşam Yemeği - Siyah Elbise',
        ),
        CalendarEvent(
          id: '3',
          date: now.add(const Duration(days: 2)),
          title: 'Hafta Sonu Yürüyüşü - Spor Kombin',
        ),
      ];

      state = state.copyWith(isLoading: false, events: mockEvents);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(selectedDay: selectedDay, focusedDay: focusedDay);
  }

  void changeFormat(CalendarFormat format) {
    state = state.copyWith(calendarFormat: format);
  }

  void changePage(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
  }

  void addEvent(CalendarEvent event) {
    state = state.copyWith(events: [...state.events, event]);
  }
}

// Global Provider
final styleCalendarViewModelProvider =
    NotifierProvider<StyleCalendarViewModel, StyleCalendarState>(() {
  return StyleCalendarViewModel();
});
