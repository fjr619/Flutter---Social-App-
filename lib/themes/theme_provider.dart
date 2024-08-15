/*

THEME PROVIDER

This help us change the app from dark to light mode

*/

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/themes/dark_mode.dart';
import 'package:flutter_twitter_clone/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  //initially, set it as light mode
  ThemeData _themeData = lightMode;

  //get the current theme
  ThemeData get themeData => _themeData;

  //is it dark mode currently?
  bool get isDarkMode => _themeData == darkMode;

  //set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

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
}
