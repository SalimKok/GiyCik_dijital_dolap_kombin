import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/style_calendar/repository/calendar_repository.dart';
import 'package:gircik/data/models/calendar_event.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  late MockCalendarRepository mockCalendarRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      CalendarEvent(id: 'dummy', title: 'dummy', date: DateTime.now()),
    );
  });

  setUp(() {
    mockCalendarRepository = MockCalendarRepository();
    
    // Default mock response
    when(() => mockCalendarRepository.getEvents()).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        calendarRepositoryProvider.overrideWithValue(mockCalendarRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final event1 = CalendarEvent(
    id: 'E1',
    title: 'Toplantı',
    date: DateTime.now(),
  );
  
  final event2 = CalendarEvent(
    id: 'E2',
    title: 'Akşam Yemeği',
    date: DateTime.now().add(const Duration(days: 2)),
  );

  group('StyleCalendarViewModel Tests', () {
    test('initial state loads events from repository', () async {
      when(() => mockCalendarRepository.getEvents())
          .thenAnswer((_) async => [event1, event2]);
          
      container.read(styleCalendarViewModelProvider);
      
      await Future.delayed(Duration.zero);
      
      final state = container.read(styleCalendarViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.events.length, 2);
    });

    test('addEvent creates event and appends to state', () async {
      when(() => mockCalendarRepository.getEvents()).thenAnswer((_) async => []);
      when(() => mockCalendarRepository.createEvent(any())).thenAnswer((_) async => event1);
          
      final viewModel = container.read(styleCalendarViewModelProvider.notifier);
      await Future.delayed(Duration.zero); // finish init microtask
      
      await viewModel.addEvent(event1);
      
      final state = container.read(styleCalendarViewModelProvider);
      expect(state.events.length, 1);
      expect(state.events.first.title, 'Toplantı');
      
      verify(() => mockCalendarRepository.createEvent(any())).called(1);
    });
    
    test('deleteEvent removes event from state', () async {
      when(() => mockCalendarRepository.getEvents()).thenAnswer((_) async => [event1]);
      when(() => mockCalendarRepository.deleteEvent('E1')).thenAnswer((_) async {});
          
      final viewModel = container.read(styleCalendarViewModelProvider.notifier);
      await Future.delayed(Duration.zero); // finish init microtask
      
      await viewModel.deleteEvent('E1');
      
      final state = container.read(styleCalendarViewModelProvider);
      expect(state.events.isEmpty, isTrue);
      
      verify(() => mockCalendarRepository.deleteEvent('E1')).called(1);
    });
  });
}
