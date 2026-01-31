import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  late SharedPreferences _prefs;

  Locale get locale => _locale;

  LanguageProvider() {
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = _prefs.getString('selected_language') ?? 'en';
    _locale = Locale(savedLanguageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await _prefs.setString('selected_language', languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'English';
      case 'ig':
        return 'Igbo';
      case 'ha':
        return 'Hausa';
      case 'yo':
        return 'Yoruba';
      case 'pcm':
        return 'Pidgin';
      default:
        return 'English';
    }
  }

  // Get all available languages
  Map<String, String> getAvailableLanguages() {
    return {
      'en': 'English',
      'ig': 'Igbo',
      'ha': 'Hausa',
      'yo': 'Yoruba',
      'pcm': 'Pidgin',
    };
  }
}
