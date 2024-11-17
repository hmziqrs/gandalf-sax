import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  static AppProvider of(BuildContext context, [bool listen = false]) {
    return Provider.of<AppProvider>(context, listen: listen);
  }

  // Cache keys
  static const String _themeKey = 'app_theme';
  static const String _backgroundPlaybackKey = 'background_playback';

  // Default values
  ThemeMode _themeMode = ThemeMode.system;
  bool _backgroundPlayback = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get backgroundPlayback => _backgroundPlayback;

  // Initialize from cache
  Future<void> initFromCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeModeString = prefs.getString(_themeKey) ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == 'ThemeMode.$themeModeString',
      orElse: () => ThemeMode.system,
    );

    // Load background playback
    _backgroundPlayback = prefs.getBool(_backgroundPlaybackKey) ?? false;

    notifyListeners();
  }

  // Theme methods
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Cache the value
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString().split('.').last);
  }

  // Background playback methods
  Future<void> setBackgroundPlayback(bool enabled) async {
    if (_backgroundPlayback == enabled) return;

    _backgroundPlayback = enabled;
    notifyListeners();

    // Cache the value
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backgroundPlaybackKey, enabled);
  }

  // Helper method to determine if we should use dark theme
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}
