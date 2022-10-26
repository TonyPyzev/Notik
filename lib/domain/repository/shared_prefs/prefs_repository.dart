import 'package:shared_preferences/shared_preferences.dart';

import '../../../presentation/screens/settings/cubit/settings_cubit.dart';

class PrefsRepository {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SettingsCubit _cubit;

  PrefsRepository(this._cubit) {
    _cubit.stream.listen((state) async {
      await _saveSettings(state);
    });
  }

  Future<SettingsState> fetchState() async {
    final prefs = await _prefs;
    final state = SettingsState(
      isDarkTheme: prefs.getBool('isDarkTheme') ?? defaultState.isDarkTheme,
      isMessageLeftAlign: prefs.getBool('isMessageLeftAlign') ??
          defaultState.isMessageLeftAlign,
      isDateBubbleHiden:
          prefs.getBool('isDateBubbleHiden') ?? defaultState.isDateBubbleHiden,
      fontSize: prefs.getDouble('fontSize') ?? defaultState.fontSize,
    );

    return state;
  }

  Future<void> _saveSettings(SettingsState state) async {
    final prefs = await _prefs;
    final prevState = await fetchState();

    if (prevState.isDarkTheme != state.isDarkTheme) {
      await prefs.setBool('isDarkTheme', state.isDarkTheme);
    }
    if (prevState.isMessageLeftAlign != state.isMessageLeftAlign) {
      await prefs.setBool('isMessageLeftAlign', state.isMessageLeftAlign);
    }
    if (prevState.isDateBubbleHiden != state.isDateBubbleHiden) {
      await prefs.setBool('isDateBubbleHiden', state.isDateBubbleHiden);
    }
    if (prevState.fontSize != state.fontSize) {
      await prefs.setDouble('fontSize', state.fontSize);
    }
  }
}
