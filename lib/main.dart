// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimalauncher/pages/home_page.dart';
import 'package:minimalauncher/pages/left_screen.dart';
import 'package:minimalauncher/pages/right_screen.dart';
import 'package:minimalauncher/pages/widgets/app_drawer.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
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

  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load preferences from shared preferences
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(prefsShowWallpaper)) {
      prefs.setBool(prefsShowWallpaper, false);
    }
    if (!prefs.containsKey(prefsSelectedColor)) {
      prefs.setInt(prefsSelectedColor, Color.fromRGBO(228, 228, 228, 1).value);
    }
    if (!prefs.containsKey(prefsTextColor)) {
      prefs.setInt(prefsTextColor, Color.fromRGBO(84, 84, 84, 1).value);
    }

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
    double appDrawerHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    Brightness iconsBrightness =
        ThemeData.estimateBrightnessForColor(selectedColor) == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          _pageController.jumpToPage(1);
        },
        child: Scaffold(
          backgroundColor: showWallpaper ? Colors.transparent : selectedColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              systemNavigationBarColor:
                  showWallpaper ? Colors.transparent : selectedColor,
              systemNavigationBarIconBrightness: iconsBrightness,
              statusBarColor:
                  showWallpaper ? Colors.transparent : selectedColor,
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
                    openAppDrawer(context, appDrawerHeight);
                  }
                },
                onLongPress: () {
                  // HapticFeedback.heavyImpact();
                  // Open app settings (now moved to Left Screen)
                },
                child: PageView(
                  controller: _pageController,
                  pageSnapping: true,
                  physics: const SnappyScrollPhysics(), // custom physics
                  children: [
                    LeftScreen(),
                    HomeScreen(key: _homeScreenKey),
                    RightScreen(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void openAppDrawer(BuildContext buildContext, double height) async {
    await _loadPreferences();

    // Open the app drawer and wait for a package name to be selected
    if (!buildContext.mounted) return;
    final String? selectedPackage = await showModalBottomSheet<String>(
      context: buildContext,
      isScrollControlled: true,
      builder: (BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height),
        child: AppDrawer(
          autoFocusSearch: true,
          bgColor: selectedColor,
          textColor: textColor,
        ),
      ),
    );

    if (selectedPackage != null) {
      HapticFeedback.mediumImpact();
      InstalledApps.startApp(selectedPackage);
    }

    _refreshScreens();
  }

  void _refreshScreens() {
    _homeScreenKey.currentState?.refresh();
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

class SnappyScrollPhysics extends PageScrollPhysics {
  const SnappyScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  SnappyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappyScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingDistance => 1.0;
  @override
  double get minFlingVelocity => 50.0;
  @override
  double get maxFlingVelocity => 2000.0;

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 70,
        stiffness: 800,
        damping: 1,
      );
}
