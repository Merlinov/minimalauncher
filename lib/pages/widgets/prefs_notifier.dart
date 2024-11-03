import 'package:flutter/material.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesNotifier extends ChangeNotifier {
  bool is24HourFormat = false;
  Color textColor = Colors.black;
  Color selectedColor = Colors.white;

  PreferencesNotifier() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    is24HourFormat = prefs.getBool(prefsIs24HourFormat) ?? true;
    int? textColorValue = prefs.getInt(prefsTextColor);
    if (textColorValue != null) {
      textColor = Color(textColorValue);
    }
    int? selectedColorValue = prefs.getInt(prefsSelectedColor);
    if (selectedColorValue != null) {
      selectedColor = Color(selectedColorValue);
    }
    notifyListeners();
  }

  Future<void> reloadPrefs() async {
    await _loadPrefs();
  }
}
