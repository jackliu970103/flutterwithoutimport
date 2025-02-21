import 'package:flutter/material.dart';
import 'package:flutterwithoutimport/Timer.dart';

class WeeklySummary extends StatefulWidget {
  final List<Task> workList;
  final List<Task> restList;

  WeeklySummary({ required this.workList, required this.restList}) ;

  @override
  State<WeeklySummary> createState() => _WeeklySummaryState();
}

class _WeeklySummaryState extends State<WeeklySummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Canvas()
          ],
        ),
      ),
    );
  }
}
