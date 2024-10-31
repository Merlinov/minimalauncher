import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:minimalauncher/pages/widgets/calendar_view.dart';
import 'package:minimalauncher/variables/strings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';

class LeftScreen extends StatefulWidget {
  const LeftScreen({super.key});

  @override
  State<LeftScreen> createState() => _LeftScreenState();
}

class _LeftScreenState extends State<LeftScreen> {
  final TextEditingController weatherApiKeyController = TextEditingController();

  late SharedPreferences _prefs;
  Color textColor = Colors.black;
  Color selectedColor = Colors.white;
  Color accentColor = Colors.blue[200]!;

  String WEATHERMAP_API_KEY = "";
  String _temperature = "--";
  String _weatherLocation = "Location";
  String _weatherSummary = "Summary";

  @override
  void initState() {
    _loadPreferences();

    super.initState();
  }

  // Load preferences from shared preferences
  _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedColor = Color(_prefs.getInt(prefsSelectedColor)!);
      textColor = Color(_prefs.getInt(prefsTextColor)!);
      accentColor = Color(_prefs.getInt(prefsAccentColor)!);

      WEATHERMAP_API_KEY = _prefs.getString(prefsWeatherApiKey) ?? "";
      _temperature = _prefs.getString(prefsWeatherTemp) ?? "--";
      _weatherSummary = _prefs.getString(prefsWeatherDesc) ?? "Summary";
      _weatherLocation = _prefs.getString(prefsWeatherLocation) ?? "Location";
    });
  }

  Future<void> savePrefs(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Column(
        children: [
          quickSettings(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          temperatureWidget(context),
          Expanded(child: Container()),
          calendar(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        ],
      ),
    );
  }

  Widget quickSettings(BuildContext buildContext) {
    return SizedBox(
      height: MediaQuery.of(buildContext).size.height * 0.1,
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              width: MediaQuery.of(buildContext).size.width * 0.44,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wallpaper_rounded,
                    color: textColor,
                    size: 36,
                  ),
                  Container(width: 10),
                  Text(
                    "change\nwallpaper",
                    style: TextStyle(
                      fontFamily: fontNormal,
                      fontSize: 16,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              HapticFeedback.mediumImpact();
              _changeWallpaper(context);
            },
          ),
          Expanded(child: Container()),
          GestureDetector(
            child: Container(
              width: MediaQuery.of(buildContext).size.width * 0.44,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_launch_outlined,
                    color: textColor,
                    size: 36,
                  ),
                  Container(width: 10),
                  Text(
                    "change\nlauncher",
                    style: TextStyle(
                      fontFamily: fontNormal,
                      fontSize: 16,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              HapticFeedback.mediumImpact();
              changeLauncher();
            },
          ),
        ],
      ),
    );
  }

  Widget temperatureWidget(BuildContext buildContext) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _temperature = "--";
          _getWeather();
        });
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        searchGoogle("weather");
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.thermostat_rounded,
              color: textColor,
              size: 36,
            ),
            Container(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$_temperature°C",
                  style: TextStyle(
                    fontFamily: fontNormal,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.25,
                  ),
                ),
                Text(
                  _weatherLocation,
                  style: TextStyle(
                    fontFamily: fontNormal,
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                    height: 1.25,
                  ),
                ),
                Container(height: 2),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    _weatherSummary,
                    style: TextStyle(
                      fontFamily: fontNormal,
                      fontSize: 11,
                      color: textColor.withOpacity(0.8),
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget calendar() {
    return CustomCalendarView(
      initialDate: DateTime.now(),
      bgColor: selectedColor,
      textColor: textColor,
      accentColor: accentColor,
      fontFamily: fontNormal,
      eventDates: [
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 2)),
      ],
    );
  }

  // HELPER FUNCTIONS----------------------------------------------------------------------------------------

  Future<void> _changeWallpaper(BuildContext buildContext) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    File file;

    if (result != null) {
      file = File(result.files.single.path!);
    } else {
      ScaffoldMessenger.of(buildContext).showSnackBar(
        const SnackBar(
          content: Text(
            'No wallpaper selected',
          ),
        ),
      );
      return;
    }

    int location = WallpaperManager.BOTH_SCREEN;
    await WallpaperManager.setWallpaperFromFile(
      file.path,
      location,
    );
  }

  Future<void> _getWeather() async {
    try {
      if (!await Permission.location.isGranted) {
        await Permission.location.request();
      }

      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));

      WeatherFactory wf = WeatherFactory(WEATHERMAP_API_KEY);

      Weather weather = await wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      // Get and format the weather description to title case
      String description = (weather.weatherDescription ?? "Clear")
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');

      // Collect additional weather details: feels like, min, max
      String feelsLike = weather.tempFeelsLike?.celsius?.toInt().toString() ??
          weather.temperature!.celsius!.toInt().toString();
      String minTemp = weather.tempMin?.celsius?.toInt().toString() ??
          weather.temperature!.celsius!.toInt().toString();
      String maxTemp = weather.tempMax?.celsius?.toInt().toString() ??
          weather.temperature!.celsius!.toInt().toString();
      int humidity = weather.humidity != null ? weather.humidity!.toInt() : 0;

      // Create a detailed weather summary
      String weatherSummary = "$description. Feels Like: $feelsLike°C.\n"
          "Min: $minTemp°C, Max: $maxTemp°C. Humidity: $humidity%.";

      setState(() {
        savePrefs(
            prefsWeatherTemp, weather.temperature!.celsius!.toInt().toString());
        savePrefs(prefsWeatherLocation, weather.areaName!);
        savePrefs(prefsWeatherDesc, weatherSummary);
        _loadPreferences();
      });
    } catch (e) {
      showModalBottomSheet(
        context: context,
        backgroundColor: selectedColor,
        builder: (BuildContext context) {
          return SizedBox(
            width: double.maxFinite,
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                Text(
                  "Enter your OpenWeather API:",
                  style: TextStyle(
                    fontFamily: fontNormal,
                    fontSize: 20,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  margin: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: weatherApiKeyController,
                    style: TextStyle(
                      fontFamily: fontNormal,
                      fontSize: 16,
                      color: textColor,
                    ),
                    onTap: () {
                      weatherApiKeyController.text = WEATHERMAP_API_KEY;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      savePrefs(
                          prefsWeatherApiKey, weatherApiKeyController.text);
                      _loadPreferences();
                    });
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(textColor),
                    foregroundColor: WidgetStateProperty.all(selectedColor),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    child: Text(
                      'Save API Key',
                      style: TextStyle(
                        fontFamily: fontNormal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  Future<void> changeLauncher() async {
    try {
      await _channel.invokeMethod('changeLauncher');
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  Future<void> searchGoogle(String query) async {
    try {
      await _channel.invokeMethod('searchGoogle', {'query': query});
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  static const MethodChannel _channel = MethodChannel('main_channel');
}
