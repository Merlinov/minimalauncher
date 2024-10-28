// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:intl/intl.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

bool is24HourFormat = false;
Color textColor = Colors.black;

class _HomeScreenState extends State<HomeScreen> {
  int _batteryLevel = 0;

  late Timer refreshTimer;

  @override
  void initState() {
    _getBatteryPercentage();

    refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _getBatteryPercentage();
      });
    });

    _loadPreferences();

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
    });
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
        events("NOW (2:30 PM)", "Finish the launcher app."),
        events("TOMORROW (5:25 AM)", "Complete the presentation."),
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
            showSnackBar('Cannot open calendar');
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "${DateFormat.d().format(DateTime.now())} ${DateFormat.MMM().format(DateTime.now()).toUpperCase()}$homeStatsSeperator${DateFormat.E().format(DateTime.now()).toUpperCase()}$homeStatsSeperator$_batteryLevel%",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: fontNormal,
              ),
            )
          ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WhatsApp",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontFamily: fontNormal,
              ),
            ),
            Container(height: 2.0),
            Text(
              "YouTube",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontFamily: fontNormal,
              ),
            ),
            Container(height: 2.0),
            Text(
              "Camera",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontFamily: fontNormal,
              ),
            ),
            Container(height: 2.0),
            Text(
              "LPU Online",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontFamily: fontNormal,
              ),
            ),
            Container(height: 2.0),
            Text(
              "Academia GU",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontFamily: fontNormal,
              ),
            ),
          ],
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
