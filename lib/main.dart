// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimalauncher/variables/strings.dart';

void main() {
  runApp(Launcher());
}

class Launcher extends StatelessWidget {
  const Launcher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: 'Minimal Launcher',
      // themeMode: ThemeMode.system, // Use system theme by default
      // darkTheme: ThemeData.dark(),
      // theme: ThemeData.light(),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            statusBarColor: Colors.transparent,
          ),
        ),
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
