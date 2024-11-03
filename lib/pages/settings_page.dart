// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool showWallpaper = false;
  bool is24HourFormat = false;
  Color selectedColor = Colors.white; // Background color
  Color textColor = Colors.black; // Text color
  bool preferencesChanged = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load preferences from shared preferences
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      showWallpaper = prefs.getBool(prefsShowWallpaper) ?? false;
      is24HourFormat = prefs.getBool(prefsIs24HourFormat) ?? false;
      int? colorValue = prefs.getInt(prefsSelectedColor);
      int? textColorValue = prefs.getInt(prefsTextColor);
      if (colorValue != null) {
        selectedColor = Color(colorValue);
      }
      if (textColorValue != null) {
        textColor = Color(textColorValue);
      }
    });
  }

  // Save preferences to shared preferences
  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(prefsShowWallpaper, showWallpaper);
    prefs.setBool(prefsIs24HourFormat, is24HourFormat);
    prefs.setInt(prefsSelectedColor, selectedColor.value);
    prefs.setInt(prefsTextColor, textColor.value);
    preferencesChanged = true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).maybePop(true);
          // Navigator.pop(context, true);
        });
      },
      child: Scaffold(
        backgroundColor: selectedColor,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(
              color: textColor,
              fontFamily: fontNormal,
            ),
          ),
          foregroundColor: textColor,
          backgroundColor: selectedColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor:
                showWallpaper ? Colors.transparent : selectedColor,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Show Wallpaper',
                  style: TextStyle(
                    fontFamily: fontNormal,
                    color: textColor,
                  ),
                ),
                value: showWallpaper,
                onChanged: (value) {
                  setState(() {
                    showWallpaper = value;
                    preferencesChanged = true;
                  });
                  _savePreferences();
                },
              ),
              Text(
                "Changing the 'Show Wallpaper' setting will require you to restart the app.",
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontFamily: fontNormal,
                  fontSize: 12.0,
                ),
              ),
              if (!showWallpaper)
                ListTile(
                  title: Row(
                    children: [
                      Container(width: 15),
                      Text(
                        'Background Color:',
                        style: TextStyle(
                          color: textColor,
                          fontFamily: fontNormal,
                        ),
                      ),
                    ],
                  ),
                  trailing: GestureDetector(
                    onTap: () => _showColorPicker(context, 'background'),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                        color: selectedColor,
                      ),
                    ),
                  ),
                ),
              Divider(),
              SwitchListTile(
                title: Text(
                  '24 Hour Format',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: fontNormal,
                  ),
                ),
                value: is24HourFormat,
                onChanged: (value) {
                  setState(() {
                    is24HourFormat = value;
                    preferencesChanged = true;
                  });
                  _savePreferences();
                },
              ),
              Divider(),
              ListTile(
                title: Row(
                  children: [
                    Container(width: 15),
                    Text(
                      'Text Color:',
                      style: TextStyle(
                        color: textColor,
                        fontFamily: fontNormal,
                      ),
                    ),
                  ],
                ),
                trailing: GestureDetector(
                  onTap: () => _showColorPicker(context, 'text'),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                      color: textColor, // Show current text color
                    ),
                  ),
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }

  // Show color picker dialog
  _showColorPicker(BuildContext context, String pickerType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Pick a color',
            style: TextStyle(
              color: textColor,
              fontFamily: fontNormal,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor:
                  pickerType == 'background' ? selectedColor : textColor,
              onColorChanged: (color) {
                setState(() {
                  if (pickerType == 'background') {
                    selectedColor = color;
                  } else if (pickerType == 'text') {
                    textColor = color;
                  }
                  preferencesChanged = true;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Select'),
              onPressed: () {
                _savePreferences();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
