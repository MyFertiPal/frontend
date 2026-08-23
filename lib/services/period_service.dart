import 'package:shared_preferences/shared_preferences.dart';

class LocalPeriodService {
  static const String _key = 'tapped_days';

  DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  String _dateKey(DateTime date) {
    final d = _normalize(date);

    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');

    return '${d.year}-$month-$day';
  }

  DateTime? _parseStoredDate(String value) {
    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return null;
    }

    return _normalize(parsed);
  }

  /// ============================================================
  /// GET ALL PERIOD DAYS
  /// ============================================================

  Future<List<DateTime>> getPeriodLogs() async {
    final prefs = await SharedPreferences.getInstance();

    final stored =
        prefs.getStringList(_key) ?? const [];

    final dates = <DateTime>{};

    for (final value in stored) {
      final parsed = _parseStoredDate(value);

      if (parsed != null) {
        dates.add(parsed);
      }
    }

    final result = dates.toList();

    result.sort();

    return result;
  }

  /// ============================================================
  /// GET PERIOD DAYS AS A SET
  /// ============================================================

  Future<Set<DateTime>> getPeriodDaySet() async {
    final logs = await getPeriodLogs();

    return logs.toSet();
  }

  /// ============================================================
  /// SAVE ONE PERIOD DAY
  /// ============================================================

  Future<bool> savePeriod(DateTime date) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    final key = _dateKey(date);

    if (existing.contains(key)) {
      return false;
    }

    existing.add(key);

    existing.sort();

    final saved =
        await prefs.setStringList(
      _key,
      existing,
    );

    return saved;
  }

  /// ============================================================
  /// SAVE MULTIPLE PERIOD DAYS
  /// ============================================================

  Future<bool> savePeriods(
    Iterable<DateTime> dates,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    final keys =
        <String>{...existing};

    for (final date in dates) {
      keys.add(_dateKey(date));
    }

    final sorted =
        keys.toList()..sort();

    return prefs.setStringList(
      _key,
      sorted,
    );
  }

  /// ============================================================
  /// DELETE ONE PERIOD DAY
  /// ============================================================

  Future<bool> deletePeriod(
    DateTime date,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    final key = _dateKey(date);

    final removed =
        existing.remove(key);

    if (!removed) {
      return false;
    }

    await prefs.setStringList(
      _key,
      existing,
    );

    return true;
  }

  /// ============================================================
  /// DELETE MULTIPLE PERIOD DAYS
  /// ============================================================

  Future<bool> deletePeriods(
    Iterable<DateTime> dates,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    final keysToDelete =
        dates.map(_dateKey).toSet();

    final originalLength =
        existing.length;

    existing.removeWhere(
      keysToDelete.contains,
    );

    if (existing.length ==
        originalLength) {
      return false;
    }

    await prefs.setStringList(
      _key,
      existing,
    );

    return true;
  }

  /// ============================================================
  /// REPLACE ALL PERIOD DATA
  ///
  /// Useful when editing a period episode.
  /// ============================================================

  Future<bool> replacePeriods(
    Iterable<DateTime> dates,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final keys =
        dates.map(_dateKey).toSet().toList();

    keys.sort();

    return prefs.setStringList(
      _key,
      keys,
    );
  }

  /// ============================================================
  /// CLEAR ALL LOCAL PERIODS
  /// ============================================================

  Future<bool> clearAllPeriods() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.remove(_key);
  }
}