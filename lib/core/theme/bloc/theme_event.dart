import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadTheme extends ThemeEvent {}

class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ToggleThemeMode extends ThemeEvent {}
