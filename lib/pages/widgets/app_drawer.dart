import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:device_apps/device_apps.dart';

class Application {
  String name;
  String packageName;

  Application({required this.name, required this.packageName});

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      name: json['name'],
      packageName: json['packageName'],
    );
  }

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
  List<Application> apps = [];
  List<Application> recentApps = [];
  List<Application> favoriteApps = [];
  TextEditingController searchController = TextEditingController();
  String filter = "";
  bool showAllApps = false;

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
    _loadFavoriteApps();
  }

  Future<void> _loadApps() async {
    // Load cached apps data for instant display without delay
    final prefs = await SharedPreferences.getInstance();
    final String? cachedApps = prefs.getString('cachedApps');
    final String? cachedRecentApps = prefs.getString('recentApps');

    if (cachedApps != null) {
      List<dynamic> jsonApps = jsonDecode(cachedApps);
      setState(() {
        apps = jsonApps.map((app) => Application.fromJson(app)).toList();
      });
    }

    if (cachedRecentApps != null) {
      List<dynamic> jsonRecentApps = jsonDecode(cachedRecentApps);
      setState(() {
        recentApps =
            jsonRecentApps.map((app) => Application.fromJson(app)).toList();
      });
    }

    // Fetch and cache apps in the background
    _fetchAndCacheApps();
  }

  Future<void> _fetchAndCacheApps() async {
    List<AppInfo> installedApps =
        await InstalledApps.getInstalledApps(false, false);

    // Sort the apps by install time (most recent first)
    installedApps
        .sort((a, b) => b.installedTimestamp.compareTo(a.installedTimestamp));

    // Get list of all apps and only top 10 most recent
    List<Application> allAppsList = installedApps.map((app) {
      return Application(
        name: app.name,
        packageName: app.packageName,
      );
    }).toList();

    List<Application> recentAppsList =
        allAppsList.take(10).toList().reversed.toList();

    // Cache both full app list and recent apps
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedApps',
        jsonEncode(allAppsList.map((app) => app.toJson()).toList()));
    await prefs.setString('recentApps',
        jsonEncode(recentAppsList.map((app) => app.toJson()).toList()));

    // Update state in background to reflect new data
    setState(() {
      apps = allAppsList;
      recentApps = recentAppsList;
    });
  }

  Future<void> _loadFavoriteApps() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedFavorites = prefs.getString('favoriteApps');

    if (cachedFavorites != null) {
      List<dynamic> jsonFavorites = jsonDecode(cachedFavorites);
      setState(() {
        favoriteApps =
            jsonFavorites.map((app) => Application.fromJson(app)).toList();
      });
    }
  }

  Future<void> _toggleFavorite(Application app) async {
    final prefs = await SharedPreferences.getInstance();

    if (favoriteApps.any((fav) => fav.packageName == app.packageName)) {
      favoriteApps.removeWhere((fav) => fav.packageName == app.packageName);
    } else {
      favoriteApps.add(app);
    }

    await prefs.setString(
      'favoriteApps',
      jsonEncode(favoriteApps.map((fav) => fav.toJson()).toList()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    filter = filter.trim();
    final filteredApps = filter.isEmpty
        ? []
        : [
            ...apps.where((app) =>
                app.name.toLowerCase().startsWith(filter.toLowerCase())),
            ...apps.where((app) =>
                app.name.toLowerCase().contains(filter.toLowerCase()) &&
                !app.name.toLowerCase().startsWith(filter.toLowerCase())),
          ].toList();

    if (showAllApps) {
      apps.sort((a, b) => a.name.compareTo(b.name));
      return Scaffold(
        backgroundColor: widget.bgColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Expanded(
                child: ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, app.packageName);
                      },
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        InstalledApps.openSettings(app.packageName);
                        // Navigator.pop(context, null);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 16.0),
                        child: Expanded(
                          child: Text(
                            app.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 18,
                              fontFamily: fontNormal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // TODO All Apps (grid view + list view)
          // Expanded(
          //   child: Center(
          //     child: GestureDetector(
          //       onTap: () {
          //         HapticFeedback.lightImpact();
          //         setState(() {
          //           showAllApps = true;
          //         });
          //       },
          //       child: Text(
          //         "All Apps >",
          //         style: TextStyle(
          //           color: textColor,
          //           fontSize: 18,
          //           fontFamily: fontNormal,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // Displaying 10 most recently installed apps
          if (recentApps.isNotEmpty && filter.isEmpty)
            Expanded(
              flex: 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: recentApps.map((app) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, app.packageName);
                      },
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        InstalledApps.openSettings(app.packageName);
                        Navigator.pop(context, null);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                  }).toList(),
                ),
              ),
            ),

          if (recentApps.isEmpty) Expanded(child: Container()),

          if (filter.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: filteredApps.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  final isFavorite = favoriteApps
                      .any((fav) => fav.packageName == app.packageName);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, app.packageName);
                    },
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      InstalledApps.openSettings(app.packageName);
                      Navigator.pop(context, null);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: Icon(
                              isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: isFavorite ? Colors.orange : textColor,
                            ),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _toggleFavorite(app);
                            },
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              app.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontFamily: fontNormal,
                              ),
                            ),
                          ),
                        ],
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
              cursorColor: textColor,
              style: TextStyle(
                color: textColor,
                fontFamily: fontNormal,
              ),
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
