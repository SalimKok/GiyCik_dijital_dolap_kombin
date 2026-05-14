import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';

import 'package:gircik/features/style_calendar/view/widgets/style_calendar_widget.dart';
import 'package:gircik/features/style_calendar/view/widgets/calendar_event_list.dart';

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
          StyleCalendarWidget(calState: calState),
          const SizedBox(height: 16),
          Expanded(
            child: CalendarEventList(
              calState: calState,
              events: selectedEvents,
            ),
          ),
        ],
      ),
    );
  }
}
