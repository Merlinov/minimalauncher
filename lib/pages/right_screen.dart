import 'package:flutter/material.dart';
import 'package:minimalauncher/helper/app_info.dart';

class RightScreen extends StatefulWidget {
  const RightScreen({super.key});

  @override
  State<RightScreen> createState() => _RightScreenState();
}

class _RightScreenState extends State<RightScreen> {
  Future<void> _showAppPicker(BuildContext context) async {
    final selectedApp = await showDialog<AppInfo>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: AppPicker(), // Show the AppPicker inside a dialog
        );
      },
    );

    if (selectedApp != null) {
      _showAppDetails(context, selectedApp);
    }
  }

  void _showAppDetails(BuildContext context, AppInfo app) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(app.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(backgroundImage: app.icon, radius: 40),
              SizedBox(height: 10),
              Text("Package: ${app.packageName}"),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        onPressed: () {
          _showAppPicker(context);
        },
        child: const Text("Open App picker"),
      ),
    );
  }
}
