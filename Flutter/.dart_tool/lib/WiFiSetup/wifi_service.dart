import 'package:flutter/services.dart';

class WifiService {
  static const _platform = MethodChannel('com.yourcompany.app/wifi');

  // Connect to WiFi
  static Future<bool> connectToWifi(String ssid, String password) async {
    try {
      final result = await _platform.invokeMethod('connectToWifi', {
        'ssid': ssid,
        'password': password,
      });
      return result == true;
    } on PlatformException catch (e) {
      print("Failed to connect: '${e.message}'.");
      return false;
    }
  }

  // Get current WiFi status
  static Future<String?> getWifiStatus() async {
    try {
      return await _platform.invokeMethod('getWifiStatus');
    } on PlatformException catch (e) {
      print("Failed to get status: '${e.message}'.");
      return null;
    }
  }

  // Enable/Disable WiFi
  static Future<bool> setWifiEnabled(bool enabled) async {
    try {
      final result = await _platform.invokeMethod('setWifiEnabled', {
        'enabled': enabled,
      });
      return result == true;
    } on PlatformException catch (e) {
      print("Failed to set WiFi state: '${e.message}'.");
      return false;
    }
  }
}