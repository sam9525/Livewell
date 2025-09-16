import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SharedPreferencesProvider {
  static SharedPreferences? _backgroundPrefs;

  // Initialize background preferences
  static Future<void> _initializeBackgroundPrefs() async {
    try {
      if (_backgroundPrefs == null) {
        _backgroundPrefs = await SharedPreferences.getInstance();
        debugPrint('Background service preferences initialized');
      }
    } catch (e) {
      debugPrint('Error initializing background service preferences: $e');
    }
  }

  // Get background preferences
  static Future<SharedPreferences?> getBackgroundPrefs() async {
    if (_backgroundPrefs == null) {
      await _initializeBackgroundPrefs();
    }
    return _backgroundPrefs;
  }

  static SharedPreferences? get backgroundPrefs => _backgroundPrefs;
}
