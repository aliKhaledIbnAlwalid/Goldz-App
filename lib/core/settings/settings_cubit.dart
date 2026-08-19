import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({required this.themeMode, required this.locale});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );
}

class SettingsCubit extends Cubit<SettingsState> {
  final Box box;

  static const _keyTheme = 'settings_theme';
  static const _keyLocale = 'settings_locale';

  SettingsCubit(this.box)
      : super(SettingsState(
          themeMode: _readTheme(box),
          locale: _readLocale(box),
        ));

  static ThemeMode _readTheme(Box box) {
    return switch (box.get(_keyTheme)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Locale _readLocale(Box box) {
    final code = box.get(_keyLocale);
    return Locale(code == 'ar' ? 'ar' : 'en');
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await box.put(_keyTheme, mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    emit(state.copyWith(locale: locale));
    await box.put(_keyLocale, locale.languageCode);
  }
}
