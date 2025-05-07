import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ToggleThemeEvent extends ThemeEvent {}
class SetLightThemeEvent extends ThemeEvent {}
class SetDarkThemeEvent extends ThemeEvent {}
class SetSystemThemeEvent extends ThemeEvent {}

// State
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ToggleThemeEvent>((event, emit) {
      if (state.themeMode == ThemeMode.light) {
        emit(const ThemeState(ThemeMode.dark));
      } else {
        emit(const ThemeState(ThemeMode.light));
      }
    });
    on<SetLightThemeEvent>((event, emit) => emit(const ThemeState(ThemeMode.light)));
    on<SetDarkThemeEvent>((event, emit) => emit(const ThemeState(ThemeMode.dark)));
    on<SetSystemThemeEvent>((event, emit) => emit(const ThemeState(ThemeMode.system)));
  }
} 