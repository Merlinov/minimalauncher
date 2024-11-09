import 'dart:io';

import 'package:flutter/services.dart';
import 'package:minimalauncher/variables/strings.dart';

late String iconFilePath;

bool doesIconFileExist(String packageName) {
  String iconFileName = 'icon_$packageName.png';
  String iconFilePath = '/data/user/0/$launcherPackageName/cache/$iconFileName';

  File iconFile = File(iconFilePath);
  return iconFile.existsSync();
}

Future<String>? getAppIcon(String packageName) async {
  try {
    // Check if the icon file already exists
    if (doesIconFileExist(packageName)) {
      String filePath =
          '/data/user/0/$launcherPackageName/cache/icon_$packageName.png';
      iconFilePath = filePath;
      return filePath;
    }

    String? appIconPath = await _channel
        .invokeMethod('getAppIconPath', {'packageName': packageName});

    iconFilePath = appIconPath!;
    return appIconPath;
  } catch (e) {
    return "";
  }
}

const MethodChannel _channel = MethodChannel('main_channel');
