import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../storage/local_storage_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final LocalStorageService _storageService;

  ThemeBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const ThemeState()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ToggleThemeMode>(_onToggleThemeMode);
  }

  void _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) {
    final savedMode = _storageService.getThemeMode();
    if (savedMode != null) {
      if (savedMode == 'light') {
        emit(state.copyWith(themeMode: ThemeMode.light));
      } else if (savedMode == 'dark') {
        emit(state.copyWith(themeMode: ThemeMode.dark));
      } else {
        emit(state.copyWith(themeMode: ThemeMode.system));
      }
    }
  }

  Future<void> _onChangeThemeMode(ChangeThemeMode event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(themeMode: event.themeMode));
    final modeString = event.themeMode == ThemeMode.light
        ? 'light'
        : event.themeMode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _storageService.saveThemeMode(modeString);
  }

  Future<void> _onToggleThemeMode(ToggleThemeMode event, Emitter<ThemeState> emit) async {
    final isDarkNow = event.isCurrentDark ?? state.isDark();
    final newMode = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(themeMode: newMode));
    await _storageService.saveThemeMode(newMode == ThemeMode.dark ? 'dark' : 'light');
  }
}
