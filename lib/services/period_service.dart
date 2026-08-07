import 'package:shared_preferences/shared_preferences.dart';

class LocalPeriodService {
  static const String _key = 'tapped_days';

  // ------------------------------------------------------------
  // DATE ONLY
  // ------------------------------------------------------------

  String _dateOnly(DateTime date) {
    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return normalized.toIso8601String().split('T').first;
  }

  DateTime _parseDate(String value) {
    return DateTime.parse(value);
  }

  // ------------------------------------------------------------
  // GET PERIOD LOGS
  // ------------------------------------------------------------

  Future<List<DateTime>> getPeriodLogs() async {
    final prefs = await SharedPreferences.getInstance();

    final values = prefs.getStringList(_key) ?? [];

    final dates = <DateTime>[];

    for (final value in values) {
      try {
        dates.add(
          _parseDate(value),
        );
      } catch (e) {
        // Ignore invalid stored dates.
      }
    }

    dates.sort(
      (a, b) => a.compareTo(b),
    );

    return dates;
  }

  // ------------------------------------------------------------
  // SAVE PERIOD
  // ------------------------------------------------------------

  Future<void> savePeriod(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    final value = _dateOnly(date);

    if (!existing.contains(value)) {
      existing.add(value);
    }

    existing.sort();

    await prefs.setStringList(
      _key,
      existing,
    );
  }

  // ------------------------------------------------------------
  // DELETE PERIOD
  // ------------------------------------------------------------

  Future<void> deletePeriod(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    final value = _dateOnly(date);

    existing.remove(value);

    await prefs.setStringList(
      _key,
      existing,
    );
  }
}