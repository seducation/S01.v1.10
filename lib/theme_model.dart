import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color? _customBackgroundColor;

  ThemeMode get themeMode => _themeMode;
  Color? get customBackgroundColor => _customBackgroundColor;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  set customBackgroundColor(Color? color) {
    _customBackgroundColor = color;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void resetBackgroundColor() {
    _customBackgroundColor = null;
    notifyListeners();
  }
}
