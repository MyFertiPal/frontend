
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPeriodService {
  static const String _key = 'flutter.tapped_days';

  DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  String _dateKey(DateTime date) {
    final normalized = _normalize(date);

    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String value) {
    try {
      final parsed = DateTime.parse(value);

      return _normalize(parsed);
    } catch (_) {
      return null;
    }
  }

  Future<List<DateTime>> getPeriodLogs() async {
    final prefs =
        await SharedPreferences.getInstance();

    final stored =
        prefs.getStringList(_key) ?? [];

    final dates = <DateTime>[];

    for (final value in stored) {
      final date = _parseDate(value);

      if (date != null) {
        dates.add(date);
      }
    }

    dates.sort(
      (a, b) => a.compareTo(b),
    );

    return dates;
  }

  Future<void> savePeriod(DateTime date) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    final normalizedKey =
        _dateKey(date);

    if (!existing.contains(normalizedKey)) {
      existing.add(normalizedKey);
    }

    existing.sort();

    await prefs.setStringList(
      _key,
      existing,
    );

    debugPrint(
      'LOCAL PERIOD SAVED: $normalizedKey',
    );
  }

  Future<void> deletePeriod(DateTime date) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    final normalizedKey =
        _dateKey(date);

    existing.remove(normalizedKey);

    await prefs.setStringList(
      _key,
      existing,
    );

    debugPrint(
      'LOCAL PERIOD DELETED: $normalizedKey',
    );
  }

  Future<void> clearPeriods() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}