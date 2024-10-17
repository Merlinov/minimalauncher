// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:minimalauncher/pages/home_page.dart';
import 'package:minimalauncher/pages/left_screen.dart';
import 'package:minimalauncher/pages/right_screen.dart';
import 'package:minimalauncher/pages/settings_page.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(Launcher());
}

class Launcher extends StatefulWidget {
  const Launcher({super.key});

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  bool showWallpaper = true;
  Color selectedColor = Colors.white;

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
      showWallpaper = prefs.getBool(prefsShowWallpaper) ?? true;
      int? colorValue = prefs.getInt(prefsSelectedColor);
      if (colorValue != null) {
        selectedColor = Color(colorValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            statusBarColor: showWallpaper ? Colors.transparent : selectedColor,
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
                  // TODO open search screen
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
                    print("yes");
                    setState(() {
                      _loadPreferences(); // Reload preferences to reflect changes in the clock
                    });
                  }
                });
              },
              child: PageView(
                controller: _pageController,
                physics:
                    CustomScrollPhysics(), // Apply custom physics for faster swiping
                children: [
                  LeftScreen(),
                  HomeScreen(), // Clock widget in HomeScreen
                  RightScreen(),
                ],
              ),
            );
          },
        ),
      ),
    );
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

// Custom Scroll Physics to reduce swipe drag resistance (faster)
class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  // Reduce drag to make the page swipe faster
  @override
  double get dragStartDistanceMotionThreshold => 0.1; // React faster to swipes

  @override
  double frictionFactor(double overscrollFraction) {
    return 0.0001; // Less friction for quicker swipe
  }

  @override
  double get minFlingVelocity => 700.0; // Adjust velocity threshold if needed
}
