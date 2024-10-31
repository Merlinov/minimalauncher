// ignore_for_file: prefer_const_constructors

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:minimalauncher/pages/home_page.dart';
import 'package:minimalauncher/pages/left_screen.dart';
import 'package:minimalauncher/pages/right_screen.dart';
import 'package:minimalauncher/pages/settings_page.dart';
import 'package:minimalauncher/pages/widgets/app_drawer.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';

void main() {
  runApp(Launcher());
}

class Launcher extends StatefulWidget {
  const Launcher({super.key});

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  bool showWallpaper = false;
  Color selectedColor = Colors.white;
  Color textColor = Colors.black;

  final PageController _pageController = PageController(initialPage: 1);

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
      int? colorValue = prefs.getInt(prefsSelectedColor);
      if (colorValue != null) {
        selectedColor = Color(colorValue);
      }
      int? textColorValue = prefs.getInt(prefsTextColor);
      if (textColorValue != null) {
        textColor = Color(textColorValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Brightness iconsBrightness =
        ThemeData.estimateBrightnessForColor(selectedColor) == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: showWallpaper ? Colors.transparent : selectedColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor:
                showWallpaper ? Colors.transparent : selectedColor,
            systemNavigationBarIconBrightness: iconsBrightness,
            statusBarColor: showWallpaper ? Colors.transparent : selectedColor,
            statusBarIconBrightness: iconsBrightness,
          ),
        ),
        body: Builder(
          builder: (context) {
            return GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  // Swipe down
                  expandNotification();
                } else if (details.primaryVelocity! < 0) {
                  openAppDrawer(context);
                }
              },
              onLongPress: () {
                HapticFeedback.heavyImpact();
                // Push to settings page using a valid context
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                ).then((value) {
                  // Check if preferences have been changed
                  if (value == true) {
                    setState(() {
                      _loadPreferences(); // Reload preferences to reflect changes in the clock
                    });
                  }
                });
              },
              child: PageView(
                controller: _pageController,
                // physics: ,
                children: const [
                  LeftScreen(),
                  HomeScreen(),
                  RightScreen(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void openAppDrawer(BuildContext context) async {
    // Open the app drawer and wait for a package name to be selected
    final String? selectedPackage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => AppDrawer(
        autoFocusSearch: true,
        bgColor: selectedColor,
        textColor: textColor,
      ),
    );

    if (selectedPackage != null) {
      HapticFeedback.mediumImpact();
      DeviceApps.openApp(selectedPackage);
    }
  }

  // native methods----------------------------------------------------------------------------------------------------------
  Future<void> expandNotification() async {
    try {
      await _channel.invokeMethod(nativeExpandNotification);
    } catch (e) {
      // print('Error invoking expand method: $e');
    }
  }

  static const MethodChannel _channel = MethodChannel('main_channel');
}
