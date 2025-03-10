import 'dart:async';
import 'package:flutter/services.dart';

class VibrationService {
  static const MethodChannel _channel = MethodChannel('com.example.flutterwithoutimport/vibration');

  Future<void> vibrate(int duration) async {
    try {
      await _channel.invokeMethod('vibrate', {'duration': duration});
    } on PlatformException catch (e) {
      print("Vibration failed: ${e.message}");
    }
  }
}
