import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';

enum AppThemePreference { light, auto, dark }

class ThemeModeState {
  const ThemeModeState({required this.preference, required this.resolvedMode});

  final AppThemePreference preference;
  final ThemeMode resolvedMode;

  ThemeModeState copyWith({
    AppThemePreference? preference,
    ThemeMode? resolvedMode,
  }) {
    return ThemeModeState(
      preference: preference ?? this.preference,
      resolvedMode: resolvedMode ?? this.resolvedMode,
    );
  }
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeModeState>(
      ThemeModeController.new,
    );

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeControllerProvider).resolvedMode;
});

final themePreferenceProvider = Provider<AppThemePreference>((ref) {
  return ref.watch(themeModeControllerProvider).preference;
});

class ThemeModeController extends Notifier<ThemeModeState> {
  static const _themeModeKey = 'theme_mode';

  double? _latestLux;

  @override
  ThemeModeState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_themeModeKey);

    AppThemePreference preference;
    switch (stored) {
      case 'dark':
        preference = AppThemePreference.dark;
        break;
      case 'auto':
        preference = AppThemePreference.auto;
        break;
      case 'light':
      default:
        preference = AppThemePreference.light;
        break;
    }

    return ThemeModeState(
      preference: preference,
      resolvedMode: _resolveThemeMode(preference, null, ThemeMode.light),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final preference = mode == ThemeMode.dark
        ? AppThemePreference.dark
        : AppThemePreference.light;

    state = state.copyWith(preference: preference, resolvedMode: mode);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeModeKey, preference.name);
  }

  Future<void> setAutoMode() async {
    final resolvedMode = _resolveThemeMode(
      AppThemePreference.auto,
      _latestLux,
      state.resolvedMode,
    );
    state = state.copyWith(
      preference: AppThemePreference.auto,
      resolvedMode: resolvedMode,
    );
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeModeKey, AppThemePreference.auto.name);
  }

  void applyAmbientLux(double lux) {
    _latestLux = lux;
    if (state.preference != AppThemePreference.auto) return;

    final resolvedMode = _resolveThemeMode(
      AppThemePreference.auto,
      lux,
      state.resolvedMode,
    );
    if (resolvedMode == state.resolvedMode) return;
    state = state.copyWith(resolvedMode: resolvedMode);
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      state.resolvedMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  ThemeMode _resolveThemeMode(
    AppThemePreference preference,
    double? lux,
    ThemeMode currentMode,
  ) {
    switch (preference) {
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.auto:
        if (lux == null) return ThemeMode.light;
        if (currentMode == ThemeMode.dark) {
          return lux > 90 ? ThemeMode.light : ThemeMode.dark;
        }
        return lux < 60 ? ThemeMode.dark : ThemeMode.light;
    }
  }
}
