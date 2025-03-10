import 'package:flutter/material.dart';
import 'package:flutterwithoutimport/Timer.dart';
import 'package:flutterwithoutimport/WeeklySummary.dart';
import 'package:flutterwithoutimport/splashscreen.dart';


void main() {
  runApp(MyApp());
}
class ThemeNotifitor extends ChangeNotifier{
  ThemeData _currentData;
  ThemeNotifitor( this._currentData);
  ThemeData get currentData => _currentData;
  void setTheme(ThemeData theme){
    _currentData = theme;
    notifyListeners();
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _currentTheme = ThemeData.light();

  void _updateTheme(ThemeData theme) {
    setState(() {
      _currentTheme = theme;
    });
  }
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _currentTheme,
      home: Splashscreen(updateTheme: _updateTheme,),
    );
  }
}
