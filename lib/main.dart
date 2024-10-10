// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:minimalauncher/variables/strings.dart';

void main() {
  runApp(Launcher());
}

class Launcher extends StatelessWidget {
  const Launcher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Launcher',
      themeMode: ThemeMode.system, // Use system theme by default
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: Scaffold(
        body: Center(
          child: Text(
            '10:30',
            style: TextStyle(
              fontFamily: fontTime,
              fontSize: 70,
            ),
          ),
        ),
      ),
    );
  }
}
