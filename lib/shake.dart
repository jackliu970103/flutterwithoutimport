import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class ShakeDetectorScreen extends StatefulWidget {
  @override
  _ShakeDetectorScreenState createState() => _ShakeDetectorScreenState();
}

class _ShakeDetectorScreenState extends State<ShakeDetectorScreen> {
  static const MethodChannel _channel = MethodChannel("shake_channel");
  int shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "onShake") {
        setState(() {
          shakeCount++;
        });
      }
    });
    _channel.invokeMethod("startListening");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shake Detector")),
      body: Center(
        child: Text("Shake Count: $shakeCount", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}