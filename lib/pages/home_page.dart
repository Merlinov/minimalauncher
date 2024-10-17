// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

bool is24HourFormat = false;
Color textColor = Colors.black;

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.075),
        ClockWidget(),
      ],
    );
  }
}

// CLOCK WIDGET --------------------------------------------------------------------------------
class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
      builder: (context, snapshot) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
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
            if (!is24HourFormat)
              Container(
                width: 5,
              ),
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
