import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

class AppSettings {
  final ThemeMode themeMode;
  final bool backgroundPlayback;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.backgroundPlayback = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? backgroundPlayback,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      backgroundPlayback: backgroundPlayback ?? this.backgroundPlayback,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettings()) {
    _initFromCache();
  }

  Future<void> _initFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('app_theme') ?? 'system';
    final backgroundPlayback = prefs.getBool('background_playback') ?? false;

    state = state.copyWith(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$themeModeString',
        orElse: () => ThemeMode.system,
      ),
      backgroundPlayback: backgroundPlayback,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', mode.toString().split('.').last);

    state = state.copyWith(themeMode: mode);
  }

  Future<void> setBackgroundPlayback(bool enabled) async {
    if (state.backgroundPlayback == enabled) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_playback', enabled);

    state = state.copyWith(backgroundPlayback: enabled);
  }

  bool isDarkMode(BuildContext context) {
    if (state.themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return state.themeMode == ThemeMode.dark;
  }
}
