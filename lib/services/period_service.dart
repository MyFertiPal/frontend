import 'package:shared_preferences/shared_preferences.dart';

class LocalPeriodService {

  static const String _key = "flutter.tapped_days";


  Future<List<DateTime>> getPeriodLogs() async {
    final prefs = await SharedPreferences.getInstance();

    final days = prefs.getStringList(_key) ?? [];

    return days
        .map((e) => DateTime.parse(e))
        .toList();
  }


  Future<void> savePeriod(DateTime date) async {

    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getStringList(_key) ?? [];

    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
    );


    if(!existing.contains(normalized.toIso8601String())) {
      existing.add(normalized.toIso8601String());
    }


    await prefs.setStringList(
      _key,
      existing,
    );
  }



  Future<void> deletePeriod(DateTime date) async {

    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getStringList(_key) ?? [];


    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
    );


    existing.remove(normalized.toIso8601String());


    await prefs.setStringList(
      _key,
      existing,
    );
  }

}