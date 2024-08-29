/*

THEME PROVIDER

This help us change the app from dark to light mode

*/

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/presentation/themes/dark_mode.dart';
import 'package:flutter_twitter_clone/presentation/themes/light_mode.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();

  //initially, set it as light mode
  ThemeData _themeData = lightMode;

  //get the current theme
  ThemeData get themeData => _themeData;

  //is it dark mode currently?
  bool get isDarkMode => _themeData == darkMode;

  ThemeProvider() {
    _loadThemeFromPreferences(); // Load theme on startup
  }

  //set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    // Save the theme to SharedPreferences
    _saveThemeToPreferences(themeData);

    //update the ui
    notifyListeners();
  }

  //toogle between dark and light mode
  void toogleTheme() {
    if (isDarkMode) {
      themeData = lightMode;
    } else {
      themeData = darkMode;
    }

    notifyListeners();
  }

  // Load the theme from SharedPreferences
  Future<void> _loadThemeFromPreferences() async {
    final String? themeString = _prefs.getString(_themePreferenceKey);

    if (themeString != null && themeString == 'dark') {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }

    notifyListeners(); // Notify listeners after loading the theme
  }

  // Save the theme to SharedPreferences
  Future<void> _saveThemeToPreferences(ThemeData themeData) async {
    if (themeData == darkMode) {
      await _prefs.setString(_themePreferenceKey, 'dark');
    } else {
      await _prefs.setString(_themePreferenceKey, 'light');
    }
  }
}
