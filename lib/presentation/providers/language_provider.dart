import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language Provider - Manages app language state
class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _locale = const Locale('ar'); // Default to Arabic
  bool _isLoading = true;
  
  Locale get locale => _locale;
  bool get isLoading => _isLoading;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
  String get languageCode => _locale.languageCode;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  /// Load saved language preference
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        _locale = Locale(savedLanguage);
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Change app language
  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    _locale = Locale(languageCode);
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }
  
  /// Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final newLanguage = isArabic ? 'en' : 'ar';
    await setLanguage(newLanguage);
  }
  
  /// Set Arabic
  Future<void> setArabic() => setLanguage('ar');
  
  /// Set English
  Future<void> setEnglish() => setLanguage('en');
}
