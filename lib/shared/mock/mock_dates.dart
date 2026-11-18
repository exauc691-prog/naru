final DateTime _mockToday = DateTime.now();

DateTime mockDate({int daysAgo = 0, int hour = 9, int minute = 0}) {
  final day = DateTime(
    _mockToday.year,
    _mockToday.month,
    _mockToday.day,
  ).subtract(Duration(days: daysAgo));
  return DateTime(day.year, day.month, day.day, hour, minute);
}

DateTime mockCalendarDate(int daysAgo) {
  final day = DateTime(
    _mockToday.year,
    _mockToday.month,
    _mockToday.day,
  ).subtract(Duration(days: daysAgo));
  return DateTime(day.year, day.month, day.day);
}
