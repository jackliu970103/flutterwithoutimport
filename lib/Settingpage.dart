import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterwithoutimport/main.dart';
class SettingsScreen extends StatefulWidget {
  final Function(ThemeData) updateTime;
  SettingsScreen({required this.updateTime});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool changeTheme =false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(16),child: Column(
        children: [
          SizedBox(height: 100,),
          Row(
            children: [
              Text("改變主題"),
              SizedBox(width: 10,),
              Text("明"),
              Switch(value: changeTheme, onChanged: (value){
                setState(() {
                  changeTheme =value;
                  if(changeTheme){
                    setState(() {
                      widget.updateTime(ThemeData.dark());
                    });
                  }else{
                    setState(() {
                      widget.updateTime(ThemeData.light());
                    });
                  }
                });
              }),
              Text("暗")
            ],
          ),

        ],
      ),),
    );
  }
}
