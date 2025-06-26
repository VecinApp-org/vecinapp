import 'package:intl/intl.dart';

/// Formats a DateTime into a human-readable string based on its relation to the current time.
///
/// Handles cases like "Happening Now", "Today", "Tomorrow", "This Year", and future years.
///
/// - [eventTime]: The start time of the event.
/// - [endTime]: An optional end time for the event, used for the "Happening Now" case.
/// - [locale]: The locale for formatting (e.g., 'en_US' for English, 'es_MX' for Mexican Spanish).
String formatEventDateTime(
  DateTime eventTime, {
  DateTime? endTime,
  String locale = 'es_MX',
}) {
  final DateTime now = DateTime.now();

  // A helper to check if two dates are on the same calendar day.
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Happening Now
  if (endTime != null && eventTime.isBefore(now) && endTime.isAfter(now)) {
    // Format the end time in 24-hour format (HH for 00-23)
    final endFormat = DateFormat('HH:mm', locale);
    return 'Sucediendo ahora, termina ${endFormat.format(endTime)}';
  }

  final DateTime tomorrow = now.add(const Duration(days: 1));
  final DateTime endOfWeek = now.add(const Duration(days: 7));

  // Today
  if (isSameDay(eventTime, now)) {
    final timeFormat = DateFormat('HH:mm', locale);
    return 'Hoy a las ${timeFormat.format(eventTime)}';
  }

  // Tomorrow
  if (isSameDay(eventTime, tomorrow)) {
    // EEEE for full day name, d for day of month, HH:mm for 24-hour time.
    final format = DateFormat('EEEE d, HH:mm', locale);
    return 'Mañana, ${format.format(eventTime)}';
  }

  // Within the next 7 days
  if (eventTime.isAfter(now) && eventTime.isBefore(endOfWeek)) {
    final format = DateFormat('EEEE d, HH:mm', locale);
    return format.format(eventTime); // e.g., "Friday 28, 11:00"
  }

  // Later this year
  if (eventTime.year == now.year) {
    // MMMM for full month name, d for day, h:mm a for 12-hour time with AM/PM.
    final format = DateFormat('MMMM d, h:mm a', locale);
    return format.format(eventTime);
  }

  // Case 6: "2026, August 3, 15:00" (Future year)
  // yyyy for year, MMMM for full month name, d for day, HH:mm for 24-hour time.
  final format = DateFormat('yyyy, MMMM d, HH:mm', locale);
  return format.format(eventTime);
}
