import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../domain/repository/shared_prefs/prefs_repository.dart';
import '../../../theme/themeData/dark_theme.dart';
import '../../../theme/themeData/light_theme.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  late final PrefsRepository _prefs;

  SettingsCubit() : super(defaultState) {
    _prefs = PrefsRepository(this);
    _initState();
  }

  void swithTheme() {
    emit(state.copyWith(isDarkTheme: !state.isDarkTheme));
  }

  void alingMessages() {
    emit(state.copyWith(isMessageLeftAlign: !state.isMessageLeftAlign));
  }

  void hideBubble() {
    emit(state.copyWith(isDateBubbleHiden: !state.isDateBubbleHiden));
  }

  void setFontSize(double value) {
    emit(state.copyWith(fontSize: value));
  }

  void resetState() {
    emit(defaultState);
  }

  ThemeData fetchTheme() {
    final dark = darkThemeData.copyWith(
      textTheme: TextTheme(
        headline1: TextStyle(fontSize: 11 + state.fontSize),
        headline2: TextStyle(fontSize: 13 + state.fontSize),
        headline3: TextStyle(fontSize: 17 + state.fontSize),
        headline4: TextStyle(fontSize: 19 + state.fontSize),
        headline5: TextStyle(fontSize: 23 + state.fontSize),
        headline6: TextStyle(fontSize: 29 + state.fontSize),
      ),
    );
    final light = lightThemeData.copyWith(
      textTheme: TextTheme(
        headline1: TextStyle(fontSize: 11 + state.fontSize),
        headline2: TextStyle(fontSize: 13 + state.fontSize),
        headline3: TextStyle(fontSize: 15 + state.fontSize),
        headline4: TextStyle(fontSize: 17 + state.fontSize),
        headline5: TextStyle(fontSize: 23 + state.fontSize),
        headline6: TextStyle(fontSize: 29 + state.fontSize),
      ),
    );
    return state.isDarkTheme ? dark : light;
  }

  void _initState() async {
    emit(await _prefs.fetchState());
  }
}
