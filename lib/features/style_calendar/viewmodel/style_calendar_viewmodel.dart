import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/features/style_calendar/repository/calendar_repository.dart';

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
  late CalendarRepository _repository;

  @override
  StyleCalendarState build() {
    _repository = ref.watch(calendarRepositoryProvider);
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
      final remoteEvents = await _repository.getEvents();
      state = state.copyWith(isLoading: false, events: remoteEvents);
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

  Future<void> addEvent(CalendarEvent event) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newEvent = await _repository.createEvent(event);
      state = state.copyWith(
        isLoading: false, 
        events: [...state.events, newEvent]
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateEvent(CalendarEvent event) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedEvent = await _repository.updateEvent(event);
      final newEvents = state.events.map((e) => e.id == updatedEvent.id ? updatedEvent : e).toList();
      state = state.copyWith(
        isLoading: false, 
        events: newEvents
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteEvent(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteEvent(id);
      final newEvents = state.events.where((e) => e.id != id).toList();
      state = state.copyWith(
        isLoading: false, 
        events: newEvents
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Global Provider
final styleCalendarViewModelProvider =
    NotifierProvider<StyleCalendarViewModel, StyleCalendarState>(() {
  return StyleCalendarViewModel();
});

