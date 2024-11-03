// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:intl/intl.dart';
import 'package:minimalauncher/pages/widgets/app_drawer.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

bool is24HourFormat = false;
Color textColor = Colors.black;
Color selectedColor = Colors.white;

class HomeScreenState extends State<HomeScreen> {
  int _batteryLevel = 0;
  late Timer refreshTimer;

  List<AppInfo> favoriteApps = [];

  void refresh() {
    setState(() {
      _loadPreferences();
      _loadFavoriteApps();
      // TODO load events ?
    });
  }

  @override
  void initState() {
    _loadPreferences();
    _loadFavoriteApps();
    _getBatteryPercentage();

    refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _getBatteryPercentage();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    // cancel the timer when the widget is disposed
    refreshTimer.cancel();
    super.dispose();
  }

  // Load preferences from shared preferences
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      is24HourFormat = prefs.getBool(prefsIs24HourFormat) ?? true;
      int? textColorValue = prefs.getInt(prefsTextColor);
      if (textColorValue != null) {
        textColor = Color(textColorValue);
      }
      int? selectedColorValue = prefs.getInt(prefsSelectedColor);
      if (selectedColorValue != null) {
        selectedColor = Color(selectedColorValue);
      }
    });
  }

  Future<void> _loadFavoriteApps() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedFavorites = prefs.getString('favoriteApps');

    if (cachedFavorites != null) {
      List<dynamic> jsonFavorites = jsonDecode(cachedFavorites);
      setState(() {
        favoriteApps =
            jsonFavorites.map((app) => AppInfo.fromJson(app)).toList();
      });
    }
  }

  Future<void> _saveFavoriteApps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('favoriteApps',
        jsonEncode(favoriteApps.map((app) => app.toJson()).toList()));
  }

  void _getBatteryPercentage() async {
    int battery = await Battery().batteryLevel;

    setState(() {
      _batteryLevel = battery;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.075),
        ClockWidget(),
        SizedBox(height: screenHeight * 0.025),
        statsWidget(),
        SizedBox(height: screenHeight * 0.075),
        events("NOW (2:30 PM)", "finish the launcher app."),
        events("TOMORROW (5:25 AM)", "complete the presentation."),
        Expanded(child: Container()),
        homeScreenApps(),
        Expanded(child: Container()),
        searchWidget(),
        SizedBox(height: screenHeight * 0.05),
      ],
    );
  }

  Widget statsWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: GestureDetector(
        onTap: () async {
          const String url = 'content://com.android.calendar/time/';

          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          } else {
            showSnackBar('cannot open calendar');
          }
        },
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    "${DateFormat.d().format(DateTime.now())} ${DateFormat.MMM().format(DateTime.now()).toUpperCase()}$homeStatsSeperator${DateFormat.EEEE().format(DateTime.now()).toUpperCase()}$homeStatsSeperator$_batteryLevel",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontFamily: fontNormal,
                ),
              ),
              TextSpan(
                text: '%',
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontFamily: fontNormal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget events(String title, String desc) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        children: [
          Text(
            "|",
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontFamily: fontNormal,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontFamily: fontNormal,
                  fontSize: 14.0,
                ),
              ),
              Opacity(
                opacity: 0.7,
                child: Text(
                  desc,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: fontNormal,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget homeScreenApps() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Opacity(
        opacity: 0.8,
        child: ListView.builder(
          itemCount: favoriteApps.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                InstalledApps.startApp(favoriteApps[index].packageName);
              },
              onLongPress: () {
                HapticFeedback.heavyImpact();
                editHomeScreenApp(context, index);
              },
              child: Row(
                children: [
                  Text(
                    favoriteApps[index].name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 21,
                      fontFamily: fontNormal,
                    ),
                  ),
                  Container(height: 2.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget searchWidget() {
    return Opacity(
      opacity: 0.35,
      child: Column(
        children: [
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: textColor,
            size: 20,
          ),
          Text(
            "search",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontFamily: fontNormal,
            ),
          ),
        ],
      ),
    );
  }

  // HELPER FUNCTIONS ---------------------------------------------------------------------------
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  void editHomeScreenApp(BuildContext context, int index) async {
    TextEditingController nameController =
        TextEditingController(text: favoriteApps[index].name);

    await showModalBottomSheet(
      context: context,
      backgroundColor: selectedColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Rename App',
                      labelStyle: TextStyle(
                        color: textColor,
                        fontFamily: fontNormal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(textColor),
                        ),
                        onPressed: () {
                          setState(() {
                            favoriteApps[index].name = nameController.text;
                          });
                          _saveFavoriteApps();
                          setState(() {
                            _loadPreferences();
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: selectedColor,
                            fontFamily: fontNormal,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(textColor),
                        ),
                        onPressed: () {
                          setState(() {
                            favoriteApps.removeAt(index);
                          });
                          _saveFavoriteApps();
                          setState(() {
                            _loadPreferences();
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Remove from Favorites',
                          style: TextStyle(
                            color: selectedColor,
                            fontFamily: fontNormal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(textColor),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await showModalBottomSheet(
                        context: context,
                        backgroundColor: selectedColor,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                children: [
                                  SizedBox(height: 16),
                                  Text(
                                    "Reorder Apps:",
                                    style: TextStyle(
                                      fontFamily: fontNormal,
                                      color: textColor,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Expanded(
                                    child: ReorderableListView.builder(
                                      itemCount: favoriteApps.length,
                                      onReorderStart: (index) {
                                        HapticFeedback.mediumImpact();
                                      },
                                      onReorder: (oldIndex, newIndex) async {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final item =
                                              favoriteApps.removeAt(oldIndex);
                                          favoriteApps.insert(newIndex, item);
                                        });
                                        await _saveFavoriteApps();
                                        setState(() {
                                          _loadFavoriteApps();
                                        });
                                      },
                                      itemBuilder: (context, i) {
                                        return ListTile(
                                          key: ValueKey(
                                              favoriteApps[i].packageName),
                                          title: Text(
                                            favoriteApps[i].name,
                                            style: TextStyle(
                                              color: textColor,
                                              fontFamily: fontNormal,
                                            ),
                                          ),
                                          trailing: Icon(
                                            Icons.drag_handle_rounded,
                                            color: textColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Text(
                      'Reorder Apps',
                      style: TextStyle(
                        color: selectedColor,
                        fontFamily: fontNormal,
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            );
          },
        );
      },
    );

    setState(() {
      _loadFavoriteApps();
    });
  }
}

// CLOCK WIDGET --------------------------------------------------------------------------------
class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: StreamBuilder<int>(
        stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
        builder: (context, snapshot) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                child: Text(
                  is24HourFormat
                      ? formattedTime24(DateTime.now())
                      : formattedTime12(DateTime.now()),
                  style: TextStyle(
                    fontSize: 72,
                    fontFamily: fontTime,
                    letterSpacing: 1.5,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    height: .9,
                  ),
                ),

                // date clicked
                onTap: () {
                  FlutterAlarmClock.showAlarms();
                },
              ),
              if (!is24HourFormat) SizedBox(width: 5),
              if (!is24HourFormat)
                Text(
                  getTimeAbbr(DateTime.now()),
                  style: TextStyle(
                    fontSize: 22,
                    color: textColor,
                    fontFamily: fontTime,
                    fontWeight: FontWeight.w100,
                    height: 1.4,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String formattedTime12(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    return '${hour > 12 ? hour - 12 : hour}:${minute > 9 ? minute : '0$minute'}';
  }

  String formattedTime24(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    return '$hour:${minute < 10 ? '0$minute' : minute}';
  }

  String getTimeAbbr(DateTime dateTime) {
    int hour = dateTime.hour;
    return hour > 12 ? 'PM' : 'AM';
  }
}
