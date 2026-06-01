
class DateFormatter {
  /// Formats a DateTime into mm-dd-yyyy format (e.g., 04-13-2026)
  static String formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$month-$day-$year';
  }

  /// Formats a DateTime into mm-dd-yyyy, hh:mm AM/PM format
  static String formatDateWithTime(DateTime date) {
    return '${formatDate(date)}, ${formatTime(date)}';
  }

  /// Standard time formatter (hh:mm AM/PM)
  static String formatTime(DateTime date) {
    int hour = date.hour;
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
