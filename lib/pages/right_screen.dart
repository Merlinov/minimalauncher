import 'package:flutter/material.dart';

class RightScreen extends StatefulWidget {
  const RightScreen({super.key});

  @override
  State<RightScreen> createState() => _RightScreenState();
}

class _RightScreenState extends State<RightScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(),
    );
  }
}
