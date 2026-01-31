import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Custom Material Localizations delegate that provides fallback for unsupported languages
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // Languages supported by Flutter's GlobalMaterialLocalizations
    const supportedLanguages = [
      'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'ar',
      // Add more if needed
    ];

    // If the language is supported, use it
    if (supportedLanguages.contains(locale.languageCode)) {
      return SynchronousFuture<MaterialLocalizations>(
        await GlobalMaterialLocalizations.delegate.load(locale),
      );
    }

    // Otherwise, fallback to English
    const fallbackLocale = Locale('en', 'US');
    return SynchronousFuture<MaterialLocalizations>(
      await GlobalMaterialLocalizations.delegate.load(fallbackLocale),
    );
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Custom Cupertino Localizations delegate that provides fallback for unsupported languages
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    // Languages supported by Flutter's GlobalCupertinoLocalizations
    const supportedLanguages = [
      'en',
      'es',
      'fr',
      'de',
      'it',
      'pt',
      'ru',
      'zh',
      'ja',
      'ko',
      'ar',
    ];

    // If the language is supported, use it
    if (supportedLanguages.contains(locale.languageCode)) {
      return SynchronousFuture<CupertinoLocalizations>(
        await GlobalCupertinoLocalizations.delegate.load(locale),
      );
    }

    // Otherwise, fallback to English
    const fallbackLocale = Locale('en', 'US');
    return SynchronousFuture<CupertinoLocalizations>(
      await GlobalCupertinoLocalizations.delegate.load(fallbackLocale),
    );
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

/// Custom Widgets Localizations delegate that provides fallback for unsupported languages
class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) async {
    // Languages supported by Flutter's GlobalWidgetsLocalizations
    const supportedLanguages = [
      'en',
      'es',
      'fr',
      'de',
      'it',
      'pt',
      'ru',
      'zh',
      'ja',
      'ko',
      'ar',
    ];

    // If the language is supported, use it
    if (supportedLanguages.contains(locale.languageCode)) {
      return SynchronousFuture<WidgetsLocalizations>(
        await GlobalWidgetsLocalizations.delegate.load(locale),
      );
    }

    // Otherwise, fallback to English
    const fallbackLocale = Locale('en', 'US');
    return SynchronousFuture<WidgetsLocalizations>(
      await GlobalWidgetsLocalizations.delegate.load(fallbackLocale),
    );
  }

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}
