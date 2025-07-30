import 'package:intl/intl.dart';

/// Formats a DateTime into a human-readable string based on its relation to the current time.
///
/// Handles cases like "Happening Now", "Today", "Tomorrow", "This Year", and future years.
///
/// - [startTime]: The start time of the event.
/// - [endTime]: An optional end time for the event, used for the "Happening Now" case.
/// - [locale]: The locale for formatting (e.g., 'en_US' for English, 'es_MX' for Mexican Spanish).
String formatDateTime(
  DateTime startTime, {
  DateTime? endTime,
  String locale = 'es_MX',
}) {
  final DateTime now = DateTime.now();
  final DateTime tomorrow = now.add(const Duration(days: 1));
  final DateTime endOfWeek = now.add(const Duration(days: 7));
  final DateTime yesterday = now.subtract(const Duration(days: 1));

  // A helper to check if two dates are on the same calendar day.
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  if (endTime == null) {
    //without end time
    if (startTime.isBefore(now)) {
      //in the past
      //in the last minute
      if (startTime.isAfter(now.subtract(const Duration(minutes: 1)))) {
        //show the seconds passed "hace 2 segundos"
        return '${now.difference(startTime).inSeconds}s';
      }
      //in the last hour
      if (startTime.isAfter(now.subtract(const Duration(hours: 1)))) {
        //show the minutes passed "hace 2 minutos"
        return '${now.difference(startTime).inMinutes}m';
      }
      //in the last 24 hours
      if (startTime.isAfter(now.subtract(const Duration(days: 1)))) {
        //show the hours passed "hace 2 horas"
        return '${now.difference(startTime).inHours}h';
      }
      //in the last month
      if (startTime.isAfter(now.subtract(const Duration(days: 30)))) {
        //show the days passed "hace 2 días"
        return '${now.difference(startTime).inDays}d';
      }
      //show the date "Enero 1 2023 20:00"
      return DateFormat('MMMM dd yyyy HH:mm', locale).format(startTime);
    } else {
      //in the future
      //in the next hour
      if (startTime.isBefore(now.add(const Duration(hours: 1)))) {
        //in the next hour "En 2 minutos"
        return 'En ${startTime.difference(now).inMinutes} minutos';
      }
      //later today
      if (isSameDay(startTime, now)) {
        //show the time "a las 20:00"
        final timeFormat = DateFormat('HH:mm', locale);
        return 'A las ${timeFormat.format(startTime)}';
      }
      //tomorrow
      if (isSameDay(startTime, tomorrow)) {
        //show the time "mañana a las 20:00"
        final timeFormat = DateFormat('HH:mm', locale);
        return 'Mañana a las ${timeFormat.format(startTime)}';
      }
      //next week
      if (startTime.isBefore(endOfWeek)) {
        //show the day "Lunes a las 20:00"
        final dayFormat = DateFormat('EEEE', locale);
        final timeFormat = DateFormat('HH:mm', locale);
        return '${dayFormat.format(startTime)} a las ${timeFormat.format(startTime)}';
      }
      //show the date "Enero 1 2023 20:00"
      return DateFormat('MMMM dd yyyy HH:mm', locale).format(startTime);
    }
  } else {
    //with end time
    if (endTime.isBefore(now)) {
      //already ended
      //started and ended in different days
      if (!isSameDay(startTime, endTime)) {
        //show the date "Enero 1 2023 a Enero 2 2023"
        final startDateFormat = DateFormat('MMMM dd yyyy', locale);
        final endDateFormat = DateFormat('MMMM dd yyyy', locale);
        return '${startDateFormat.format(startTime)} a ${endDateFormat.format(endTime)}';
      }
      //show the date "Enero 1 2023 20:00 - 21:00"
      final startDateFormat = DateFormat('MMMM dd yyyy HH:mm', locale);
      final endDateFormat = DateFormat('HH:mm', locale);
      return '${startDateFormat.format(startTime)} - ${endDateFormat.format(endTime)}';
    } else {
      if (startTime.isBefore(now)) {
        //happening now
        late final String initialString;
        if (isSameDay(startTime, now)) {
          //started today
          initialString =
              'hoy ${DateFormat('HH:mm', locale).format(startTime)}';
        } else if (isSameDay(startTime, yesterday)) {
          //started yesterday
          initialString =
              'ayer ${DateFormat('HH:mm', locale).format(startTime)}';
        } else {
          //started in the past
          initialString = DateFormat('MMMM dd yyyy', locale).format(startTime);
        }
        late final String endingString;
        if (isSameDay(endTime, now)) {
          //ended today
          endingString = 'hoy ${DateFormat('HH:mm', locale).format(endTime)}';
        } else if (isSameDay(endTime, tomorrow)) {
          //ended tomorrow
          endingString =
              'mañana ${DateFormat('HH:mm', locale).format(endTime)}';
        } else {
          //ended in the future
          endingString = DateFormat('MMMM dd yyyy', locale).format(endTime);
        }
        return 'Comenzó $initialString - Termina $endingString';
      } else {
        //has not started
        if (isSameDay(startTime, endTime)) {
          //start and end on the same day
          //tomorrow
          if (isSameDay(startTime, tomorrow)) {
            //show the time "mañana de 20:00 a 21:00"
          }
          //next week
          if (startTime.isBefore(endOfWeek)) {
            //show the day "Lunes de 20:00 a 21:00"
            final dayFormat = DateFormat('EEEE', locale);
            final startDateFormat = DateFormat('HH:mm', locale);
            final endDateFormat = DateFormat('HH:mm', locale);
            return '${dayFormat.format(startTime)} de ${startDateFormat.format(startTime)} a ${endDateFormat.format(endTime)}';
          }
          //show the date "Enero 1 2023 20:00 - 21:00"
          final startDateFormat = DateFormat('MMMM dd yyyy HH:mm', locale);
          final endDateFormat = DateFormat('HH:mm', locale);
          return '${startDateFormat.format(startTime)} - ${endDateFormat.format(endTime)}';
        } else {
          //starts and ends in different days
          late final String initialString;
          //starts today
          if (isSameDay(startTime, now)) {
            initialString = 'Hoy';
          }
          //starts tomorrow
          else if (isSameDay(startTime, tomorrow)) {
            initialString = 'Mañana';
          }
          //starts this week
          else if (startTime.isBefore(endOfWeek)) {
            //show the day "el Lunes"
            final dayFormat = DateFormat('EEEE', locale);
            initialString = dayFormat.format(startTime);
          }
          //starts in the future
          else {
            initialString =
                DateFormat('MMMM dd yyyy', locale).format(startTime);
          }
          late final String endingString;
          //ends tomorrow
          if (isSameDay(endTime, tomorrow)) {
            endingString =
                'Mañana ${DateFormat('HH:mm', locale).format(endTime)}';
          }
          //ends this week
          else if (endTime.isBefore(endOfWeek)) {
            //show the day "el Lunes"
            final dayFormat = DateFormat('EEEE', locale);
            endingString = dayFormat.format(endTime);
          }
          //ends in the future
          else {
            endingString = DateFormat('MMMM dd yyyy', locale).format(endTime);
          }
          return '$initialString - $endingString';
        }
      }
    }
  }
}
