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
    return _normalize(date).toIso8601String();
  }
 
  Future<List<DateTime>> getPeriodLogs() async {
    final prefs = await SharedPreferences.getInstance();
 
    final stored = prefs.getStringList(_key) ?? [];
 
    final dates = <DateTime>[];
 
    for (final value in stored) {
      final parsed = DateTime.tryParse(value);
 
      if (parsed != null) {
        dates.add(_normalize(parsed));
      }
    }
 
    dates.sort((a, b) => a.compareTo(b));
 
    return dates;
  }
 
  Future<void> savePeriod(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
 
    final existing = prefs.getStringList(_key) ?? [];
 
    final key = _dateKey(date);
 
    if (!existing.contains(key)) {
      existing.add(key);
    }
 
    await prefs.setStringList(
      _key,
      existing,
    );
  }
 
  Future<void> deletePeriod(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
 
    final existing = prefs.getStringList(_key) ?? [];
 
    final key = _dateKey(date);
 
    existing.remove(key);
 
    await prefs.setStringList(
      _key,
      existing,
    );
  }
 
  Future<void> clearAllPeriods() async {
    final prefs = await SharedPreferences.getInstance();
 
    await prefs.remove(_key);
  }
}