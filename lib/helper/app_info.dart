import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class AppInfo {
  final String name;
  final String packageName;
  final ImageProvider icon;

  AppInfo({required this.name, required this.packageName, required this.icon});
}

class AppPicker extends StatefulWidget {
  @override
  _AppPickerState createState() => _AppPickerState();
}

class _AppPickerState extends State<AppPicker> {
  List<AppInfo> userApps = [];

  @override
  void initState() {
    super.initState();
    _fetchInstalledApps();
  }

  Future<void> _fetchInstalledApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      onlyAppsWithLaunchIntent: true,
    );

    setState(() {
      userApps = apps.map((app) {
        return AppInfo(
          name: app.appName,
          packageName: app.packageName,
          icon:
              MemoryImage(app is ApplicationWithIcon ? app.icon : Uint8List(0)),
        );
      }).toList();
    });
  }

  void _showAppPicker() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: userApps.length,
          itemBuilder: (context, index) {
            final app = userApps[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: app.icon,
              ),
              title: Text(app.name),
              onTap: () {
                Navigator.pop(context, app);
              },
            );
          },
        );
      },
    ).then((selectedApp) {
      if (selectedApp != null) {
        _showAppDetails(selectedApp);
      }
    });
  }

  void _showAppDetails(AppInfo app) {
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
    return Scaffold(
      appBar: AppBar(title: Text("App Picker")),
      body: Center(
        child: ElevatedButton(
          onPressed: _showAppPicker,
          child: Text("Pick an App"),
        ),
      ),
    );
  }
}
