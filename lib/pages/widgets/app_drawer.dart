import 'dart:convert'; // for JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_apps/device_apps.dart';

class AppInfo {
  final String name;
  final String packageName;

  AppInfo({required this.name, required this.packageName});

  // Convert a JSON object to an AppInfo instance
  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      name: json['name'],
      packageName: json['packageName'],
    );
  }

  // Convert an AppInfo instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'packageName': packageName,
    };
  }
}

class AppDrawer extends StatefulWidget {
  final bool autoFocusSearch;
  final Color bgColor, textColor;

  const AppDrawer({
    Key? key,
    required this.autoFocusSearch,
    required this.bgColor,
    required this.textColor,
  }) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<AppInfo> apps = [];
  TextEditingController searchController = TextEditingController();
  String filter = "";

  Color get bgColor => widget.bgColor;
  Color get textColor => widget.textColor;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        HapticFeedback.lightImpact();
        filter = searchController.text;
      });
    });
    _loadApps();
  }

  // Load apps from cache or retrieve from system if cache is empty
  Future<void> _loadApps() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedApps = prefs.getString('cachedApps');

    if (cachedApps != null) {
      // Load cached apps
      List<dynamic> jsonApps = jsonDecode(cachedApps);
      setState(() {
        apps = jsonApps.map((app) => AppInfo.fromJson(app)).toList();
      });
    }

    // Fetch updated app list in the background
    _fetchAndCacheApps();
  }

  // Fetch app list from system and cache it
  Future<void> _fetchAndCacheApps() async {
    List<Application> installedApps = await DeviceApps.getInstalledApplications(
      includeAppIcons: false,
      onlyAppsWithLaunchIntent: true,
    );

    List<AppInfo> fetchedApps = installedApps.map((app) {
      return AppInfo(
        name: app.appName,
        packageName: app.packageName,
      );
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    final String jsonApps =
        jsonEncode(fetchedApps.map((app) => app.toJson()).toList());

    await prefs.setString('cachedApps', jsonApps);
    setState(() {
      apps = fetchedApps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = filter.isEmpty
        ? []
        : [
            ...apps.where((app) =>
                app.name.toLowerCase().startsWith(filter.toLowerCase())),
            ...apps.where((app) =>
                app.name.toLowerCase().contains(filter.toLowerCase()) &&
                !app.name.toLowerCase().startsWith(filter.toLowerCase())),
          ].toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: filter.isEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Center(
                      child: Text(
                        "Your favorite apps will appear here",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: fontNormal,
                          color: textColor,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredApps.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, app.packageName);
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          DeviceApps.openAppSettings(app.packageName);
                          Navigator.pop(context, null);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 16.0),
                          child: Text(
                            app.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontFamily: fontNormal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 6.0,
            ),
            child: TextField(
              controller: searchController,
              autofocus: widget.autoFocusSearch,
              decoration: InputDecoration(
                hintText: "Search apps...",
                hintStyle: TextStyle(
                  color: textColor,
                  fontFamily: fontNormal,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                HapticFeedback.mediumImpact();
                Navigator.pop(context, filteredApps[0].packageName);
              },
            ),
          ),
        ],
      ),
    );
  }
}
