import 'package:flutter/material.dart';
import 'translations_ar.dart';
import 'translations_en.dart';

/// App Localizations - Centralized translation system
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];
  
  late Map<String, String> _localizedStrings;
  
  Future<bool> load() async {
    _localizedStrings = locale.languageCode == 'ar' 
        ? translationsAr 
        : translationsEn;
    return true;
  }
  
  String translate(String key, {Map<String, String>? params}) {
    String text = _localizedStrings[key] ?? key;
    
    if (params != null) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value);
      });
    }
    
    return text;
  }
  
  // Shorthand getter
  String t(String key, {Map<String, String>? params}) => translate(key, params: params);
  
  // Check if RTL
  bool get isRTL => locale.languageCode == 'ar';
  
  // Get current language code
  String get languageCode => locale.languageCode;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for easy access
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String t(String key, {Map<String, String>? params}) => l10n.translate(key, params: params);
  bool get isRTL => l10n.isRTL;
}
