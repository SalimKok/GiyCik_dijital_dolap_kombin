class CalendarEvent {
  final String id;
  final DateTime date;
  final String title;

  const CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
  });

  CalendarEvent copyWith({
    String? id,
    DateTime? date,
    String? title,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
    );
  }
}
